import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/rental.dart';
import '../repositories/rental_repository.dart';
import '../services/websocket_service.dart';

class RentalProvider with ChangeNotifier {
  final RentalRepository _repository = RentalRepository();
  final WebSocketService _wsService = WebSocketService();

  List<Rental> _rentals = [];
  List<Rental> get rentals => _rentals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  RentalProvider() {
    // Initialize WebSocket in background - don't await, don't block
    _initWebSocket();
  }

  // Stream controller for notifications
  final StreamController<Rental> _notificationController = StreamController<Rental>.broadcast();
  Stream<Rental> get notificationStream => _notificationController.stream;

  void _initWebSocket() {
    // Connect in background (fire and forget)
    _wsService.connect().then((_) {
      // Once connected (or failed silently), listen to the stream
      _wsService.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            final newRental = Rental.fromJson(jsonData);
            _notificationController.add(newRental);
          } catch (e) {
            print("Error parsing websocket data: $e");
          }
        },
        onError: (error) {
          print("WebSocket stream error: $error");
        },
      );
    }).catchError((e) {
      // Connection failed - that's fine, we're offline
      print("WebSocket init failed (offline): $e");
    });
  }
  
  Future<void> fetchRentals() async {
    _isLoading = true;
    _error = null; 
    notifyListeners();

    // 1. Load Local Data Immediately
    try {
      final localData = await _repository.getLocalRentals();
      _rentals = localData;
    } catch (e) {
      print("Local load error: $e");
    }

    // CRITICAL: Stop loading HERE so UI becomes interactive immediately
    // even if list is empty or offline.
    _isLoading = false; 
    notifyListeners();

    // 2. Sync with Server (Background)
    try {
      final freshData = await _repository.syncAndGetRentals();
      _rentals = freshData;
      notifyListeners(); // Update UI with fresh data if sync succeeded
    } catch (e) {
      print("Sync error: $e");
      // Do nothing, we already showed local data
    }
  }

  Future<Rental?> getRentalDetails(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final rental = await _repository.getRentalDetails(id);
      _isLoading = false;
      notifyListeners();
      return rental;
    } catch (e) {
      _error = "Failed to get details: $e";
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> addRental(Rental rental) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newRental = await _repository.addRental(rental);
       // We can just refetch or add to list if we trust return
       // But _repository.addRental might return the local obj or api obj
       // Easiest is to refresh:
       await fetchRentals();
    } catch (e) {
      _error = "Saved locally. Will sync when online.";
      await fetchRentals();
    }
    _isLoading = false; // fetchRentals sets it, but good to ensure
    notifyListeners(); 
  }

  Future<bool> deleteRental(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteRental(id);
      _rentals.removeWhere((r) => r.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Failed to delete rental: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reports
  Future<List<Map<String, dynamic>>> getMonthlySpending() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rentals = await _repository.getAllRentalsForReports();
      // Compute monthly totals
      // Map "YYYY-MM" -> total
      Map<String, double> totals = {};
      for (var r in rentals) {
        // Assume date is YYYY-MM-DD
        if (r.date.length >= 7) {
          String month = r.date.substring(0, 7);
          totals[month] = (totals[month] ?? 0) + r.amount;
        }
      }
      
      List<Map<String, dynamic>> result = totals.entries.map((e) => {
        'month': e.key,
        'amount': e.value
      }).toList();
      
      // Descending order
      result.sort((a, b) => b['amount'].compareTo(a['amount']));
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
       _error = "Failed to load report: $e";
       _isLoading = false;
       notifyListeners();
       return [];
    }
  }

  // Insights
  Future<List<Map<String, dynamic>>> getTopCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rentals = await _repository.getAllRentalsForReports();
      Map<String, double> totals = {};
      for (var r in rentals) {
        totals[r.category] = (totals[r.category] ?? 0) + r.amount;
      }
      
      List<Map<String, dynamic>> result = totals.entries.map((e) => {
        'category': e.key,
        'amount': e.value
      }).toList();
      
      // Descending order
      result.sort((a, b) => b['amount'].compareTo(a['amount']));
      
      _isLoading = false;
      notifyListeners();
      // Top 3
      return result.take(3).toList();
    } catch (e) {
       _error = "Failed to load insights: $e";
       _isLoading = false;
       notifyListeners();
       return [];
    }
  }
}