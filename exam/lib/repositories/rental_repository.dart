import 'package:logger/logger.dart';
import '../models/rental.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class RentalRepository {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Logger _logger = Logger();

  // Just get what we have locally (Instant)
  Future<List<Rental>> getLocalRentals() async {
    return await _dbHelper.getRentals();
  }

  // Try to update from server, then return latest local data
  Future<List<Rental>> syncAndGetRentals() async {
    try {
      _logger.i('Repository: Syncing rentals from API');
      final apiRentals = await _apiService.getRentals().timeout(
        const Duration(seconds: 2), 
        onTimeout: () {
          throw Exception('Connection timed out');
        },
      );
      await _dbHelper.insertRentals(apiRentals);
    } catch (e) {
      _logger.w('Repository: Server offline or timeout: $e. Using local data.');
      // Fallback implicitly handled below
    } 
    return await _dbHelper.getRentals();
  }

  // Deprecated: keeping for compatibility if needed, but prefer split usage
  Future<List<Rental>> getRentals() async {
    return syncAndGetRentals();
  }

  Future<Rental> getRentalDetails(int id) async {
    try {
      final rental = await _apiService.getRental(id);
      await _dbHelper.insertRental(rental); 
      return rental;
    } catch (e) {
      _logger.w('Repository: Failed to fetch detail $id from API. Trying local.');
      final localRental = await _dbHelper.getRental(id);
      if (localRental != null) {
        return localRental;
      }
      throw Exception('Rental not found locally or remotely');
    }
  }

  Future<Rental> addRental(Rental rental) async {
    try {
      final newRental = await _apiService.createRental(rental);
      // API call succeeded, save the server version (with correct ID) to DB
      await _dbHelper.insertRental(newRental);
      return newRental;
    } catch (e) {
      _logger.w('Repository: Failed to add rental to API. Saving locally ($e).');
      // API failed. Save the local version to DB so it persists.
      // Note: This rental might have null ID. DB usually auto-increments if ID is null.
      // We need to ensure we can handle that. 
      await _dbHelper.insertRental(rental);
      return rental;
    }
  }

  Future<void> deleteRental(int id) async {
    try {
      await _apiService.deleteRental(id);
    } catch (e) {
      _logger.w('Repository: Failed to delete from API ($e). Deleting locally anyway.');
      // We process delete locally so UI updates even if offline
    }
    await _dbHelper.deleteRental(id);
  }

  // Reports can also go here or stay in provider if they are just aggregations
  Future<List<Rental>> getAllRentalsForReports() async {
      try {
        final rentals = await _apiService.getAllRentals();
        // Maybe cache these too?
        return rentals;
      } catch (e) {
        // Fallback to local 'getRentals' if 'getAllRentals' fails?
        // Or if getAllRentals is just a specific endpoint, we might fail.
        // Assuming we fallback to local:
        return await _dbHelper.getRentals();
      }
  }
}
