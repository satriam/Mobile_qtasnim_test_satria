import 'package:flutter/material.dart';
import 'package:test_flutter/Model/modelBarang.dart';
import 'package:test_flutter/Service/serviceBarang.dart';
import 'package:test_flutter/barangform.dart';

class BarangListScreen extends StatefulWidget {
  @override
  _BarangListScreenState createState() => _BarangListScreenState();
}

class _BarangListScreenState extends State<BarangListScreen> {
  final BarangService _barangService = BarangService();
  late Future<List<Modelbarang>> _barangListFuture;
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
      _barangListFuture = _barangService.getBarangList(
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
        title: Text('Barang List'),
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
                value: 'NamaBarang',
                child: Text('Sort by Name'),
              ),
              PopupMenuItem(
                value: 'JenisBarang',
                child: Text('Sort by Type'),
              ),
              PopupMenuItem(
                value: 'IdBarang',
                child: Text('Sort by ID'),
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
            child: FutureBuilder<List<Modelbarang>>(
              future: _barangListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No barang found'));
                } else {
                  final barangList = snapshot.data!;
                  return ListView.builder(
                    itemCount: barangList.length,
                    itemBuilder: (context, index) {
                      final barang = barangList[index];
                      return ListTile(
                        title: Text(barang.namaBarang),
                        subtitle: Text(barang.jenisBarang),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _navigateToForm(barang: barang),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteBarang(barang.idBarang),
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

  void _navigateToForm({Modelbarang? barang}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BarangFormScreen(barang: barang)),
    );

    if (result != null && result is Modelbarang) {
      _fetchBarangList(); // Refresh the list after adding or editing an item
    }
  }

  void _deleteBarang(int idBarang) async {
    await _barangService.deleteBarang(idBarang);
    _fetchBarangList(); // Refresh the list after deletion
  }
}
