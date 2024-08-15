import 'package:flutter/material.dart';
import 'package:test_flutter/barang.dart';
import 'package:test_flutter/transaksi.dart';
import 'package:test_flutter/transaksiform.dart';
import 'compare.dart'; // Import the CompareItemsPage

class MenuGridPage extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Perbandingan Data',
      'icon': Icons.compare_arrows,
      'page': CompareItemsPage(),
    },
    // Add more items to the grid as needed
    {
      'title': 'Barang',
      'icon': Icons.shop_2,
      'page': BarangListScreen(), // Replace with the actual page
    },
    {
      'title': 'Transaksi',
      'icon': Icons.shop,
      'page': TransactionListScreen(), // Replace with the actual page
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Grid'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => menuItems[index]['page']),
              );
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    menuItems[index]['icon'],
                    size: 50.0,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    menuItems[index]['title'],
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
