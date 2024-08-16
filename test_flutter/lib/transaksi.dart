import 'package:flutter/material.dart';
import 'package:test_flutter/Model/modelBarang.dart';
import 'package:test_flutter/Model/modelTransaksi.dart';
import 'package:test_flutter/Service/serviceBarang.dart';
import 'package:test_flutter/Service/serviceTransaksi.dart';
import 'package:test_flutter/barangform.dart';
import 'package:test_flutter/transaksiform.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _TransactionService = TransactionService();
  late Future<List<ModelTransaction>> _TransactionListFuture;
  String _sortBy = 'NamaBarang';
  String _sortDir = 'asc';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBarangList();
  }

  void _fetchBarangList() {
    setState(() {
      _TransactionListFuture = _TransactionService.getTransactionList(
        sortBy: _sortBy,
        sortDir: _sortDir,
        searchQuery: _searchQuery,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _fetchBarangList();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'TanggalTransaksi',
                child: Text('Sort by Tanggal'),
              ),
              PopupMenuItem(
                value: 'NamaBarang',
                child: Text('Sort by Nama'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
                _sortDir == 'asc' ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _sortDir = _sortDir == 'asc' ? 'desc' : 'asc';
                _fetchBarangList();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _fetchBarangList();
              },
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ModelTransaction>>(
              future: _TransactionListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No barang found'));
                } else {
                  final transactionList = snapshot.data!;
                  return ListView.builder(
                    itemCount: transactionList.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionList[index];
                      // print(transaction.idTransaksi);
                      return ListTile(
                        title: Text(transaction.namaBarang),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jenis Barang: ${transaction.jenisBarang}'),
                            Text('Stock: ${transaction.stock}'),
                            Text(
                                'Jumlah Terjual: ${transaction.jumlahTerjual}'),
                            Text(
                                'Tanggal Transaksi: ${transaction.tanggalTransaksi}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _navigateToForm(Transaction: transaction),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteTransaction(transaction.idTransaksi),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToForm({ModelTransaction? Transaction}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TransactionFormScreen(transaction: Transaction)),
    );

    if (result != null && result is ModelTransaction) {
      _fetchBarangList();
    }
  }

  void _deleteTransaction(int idTransaction) async {
    await _TransactionService.deleteTransaction(idTransaction);
    _fetchBarangList();
  }
}
