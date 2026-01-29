import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rental_provider.dart';
import '../models/rental.dart';
import 'rental_details_screen.dart';
import 'add_rental_screen.dart';

class MainSection extends StatefulWidget {
  const MainSection({super.key});

  @override
  State<MainSection> createState() => _MainSectionState();
}

class _MainSectionState extends State<MainSection> {
  @override
  void initState() {
    super.initState();
    // Schedule fetch after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRentals();
      _setupNotifications();
    });
  }

  void _fetchRentals() {
    Provider.of<RentalProvider>(context, listen: false).fetchRentals();
  }
  
  void _setupNotifications() {
    Provider.of<RentalProvider>(context, listen: false).notificationStream.listen((rental) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New rental added: ${rental.category} on ${rental.date}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Rentals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.pushNamed(context, '/reports'),
            tooltip: 'Reports',
          ),
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () => Navigator.pushNamed(context, '/insights'),
            tooltip: 'Insights',
          ),
        ],
      ),
      body: Consumer<RentalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.rentals.isEmpty) {
             return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null && provider.rentals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchRentals,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
              // Show error as snackbar if we have data but sync failed? 
              // Or just show data and maybe a persistent indicator.
              // Requirement: "If offline, the app will display an offline message and provide a retry option"
              // If we have data, we just show it. Maybe show error in a snackbar once.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!)));
              });
          }

          return ListView.builder(
            itemCount: provider.rentals.length,
            itemBuilder: (context, index) {
              final rental = provider.rentals[index];
              return ListTile(
                title: Text('${rental.category} - ${rental.amount}'),
                subtitle: Text(rental.date),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RentalDetailsScreen(rentalId: rental.id!),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Start delete
                    final success = await provider.deleteRental(rental.id!);
                    if (!success) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.error ?? 'Delete failed')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRentalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
