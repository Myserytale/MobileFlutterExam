import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rental_provider.dart';

class ReportsSection extends StatefulWidget {
  const ReportsSection({super.key});

  @override
  State<ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends State<ReportsSection> {
  List<Map<String, dynamic>>? _data;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final data = await Provider.of<RentalProvider>(context, listen: false).getMonthlySpending();
    if (mounted) {
      setState(() {
        _data = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Spending')),
      body: Consumer<RentalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && _data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && _data == null) {
             return Center(child: Text(provider.error!));
          }
          if (_data == null || _data!.isEmpty) {
             return const Center(child: Text('No data'));
          }

          return ListView.builder(
            itemCount: _data!.length,
            itemBuilder: (context, index) {
              final item = _data![index];
              return ListTile(
                title: Text(item['month']),
                trailing: Text(item['amount'].toStringAsFixed(2)),
              );
            },
          );
        },
      ),
    );
  }
}
