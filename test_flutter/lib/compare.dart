import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompareItemsPage extends StatefulWidget {
  @override
  _CompareItemsPageState createState() => _CompareItemsPageState();
}

class _CompareItemsPageState extends State<CompareItemsPage> {
  List<dynamic> _items = [];
  String _order = 'desc'; // Default sorting order
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    String apiUrl = 'http://localhost/api_test/api.php/compare?order=$_order';
    if (_dateRange != null) {
      String startDate = _dateRange!.start.toIso8601String().split('T').first;
      String endDate = _dateRange!.end.toIso8601String().split('T').first;
      apiUrl += '&start_date=$startDate&end_date=$endDate';
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data == null || (data is List && data.isEmpty)) {
        // Data is null or empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data Tidak Ditemukan'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _items = []; // Clear the items
        });
      } else {
        setState(() {
          _items = data;
        });
      }
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      fetchItems();
    }
  }

  void _changeOrder(String order) {
    setState(() {
      _order = order;
    });
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
          PopupMenuButton<String>(
            onSelected: _changeOrder,
            itemBuilder: (BuildContext context) {
              return {'asc', 'desc'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text('Sort by $choice'),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Data Tidak Ditemukan'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item['JenisBarang']),
                  subtitle: Text('Total Terjual: ${item['TotalTerjual']}'),
                );
              },
            ),
    );
  }
}
