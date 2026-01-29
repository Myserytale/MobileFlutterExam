import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/rental.dart';

class ApiService {
  final Logger logger = Logger();

  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:2622';
    }
    return 'http://localhost:2622';
  }

  Future<List<Rental>> getRentals() async {
    logger.i('GET /rentals');
    try {
      final response = await http.get(Uri.parse('$baseUrl/rentals'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Rental.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load rentals');
      }
    } catch (e) {
      logger.e('Error getting rentals: $e');
      rethrow;
    }
  }

  Future<Rental> getRental(int id) async {
    logger.i('GET /rental/$id');
    try {
      final response = await http.get(Uri.parse('$baseUrl/rental/$id'));
      if (response.statusCode == 200) {
        return Rental.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load rental details');
      }
    } catch (e) {
      logger.e('Error getting rental $id: $e');
      rethrow;
    }
  }

  Future<Rental> createRental(Rental rental) async {
    logger.i('POST /rental');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rental'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rental.toJson()),
      );
      if (response.statusCode == 201) {
        return Rental.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create rental');
      }
    } catch (e) {
      logger.e('Error creating rental: $e');
      rethrow;
    }
  }

  Future<void> deleteRental(int id) async {
    logger.i('DELETE /rental/$id');
    try {
      final response = await http.delete(Uri.parse('$baseUrl/rental/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete rental');
      }
    } catch (e) {
      logger.e('Error deleting rental $id: $e');
      rethrow;
    }
  }

  Future<List<Rental>> getAllRentals() async {
    logger.i('GET /allRentals');
    try {
      final response = await http.get(Uri.parse('$baseUrl/allRentals'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Rental.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load all rentals');
      }
    } catch (e) {
      logger.e('Error getting all rentals: $e');
      rethrow; 
    }
  }
}
