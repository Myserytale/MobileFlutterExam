import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rental_provider.dart';
import '../models/rental.dart';

class RentalDetailsScreen extends StatefulWidget {
  final int rentalId;

  const RentalDetailsScreen({super.key, required this.rentalId});

  @override
  State<RentalDetailsScreen> createState() => _RentalDetailsScreenState();
}

class _RentalDetailsScreenState extends State<RentalDetailsScreen> {
  Rental? _rental;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetails();
    });
  }

  void _fetchDetails() async {
    final rental = await Provider.of<RentalProvider>(context, listen: false).getRentalDetails(widget.rentalId);
    if (mounted) {
        setState(() {
            _rental = rental;
            _initialized = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rental Details')),
      body: Consumer<RentalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_rental == null && _initialized) {
             return Center(child: Text('Rental not found. ${provider.error ?? ""}'));
          }
          if (_rental == null) {
              return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${_rental!.category}'),
                Text('Type: ${_rental!.type}'),
                Text('Date: ${_rental!.date}'),
                Text('Amount: ${_rental!.amount}'),
                Text('Description: ${_rental!.description}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
