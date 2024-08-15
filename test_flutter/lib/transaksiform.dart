import 'package:flutter/material.dart';
import 'package:test_flutter/Model/modelBarang.dart';
import 'package:test_flutter/Model/modelTransaksi.dart';
import 'package:test_flutter/Service/serviceBarang.dart';
import 'package:test_flutter/Service/serviceTransaksi.dart';

class TransactionFormScreen extends StatefulWidget {
  final ModelTransaction? transaction; // Null when creating a new entry
  final bool isEditing;

  TransactionFormScreen({this.transaction}) : isEditing = transaction != null;

  @override
  _TransactionFormScreenState createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stockController;
  late TextEditingController _jumlahTerjualController;
  late TextEditingController _tanggalTransaksiController;

  List<Modelbarang> _barangList = [];
  int? _selectedBarangId;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _stockController =
        TextEditingController(text: widget.transaction?.stock.toString() ?? '');
    _jumlahTerjualController = TextEditingController(
        text: widget.transaction?.jumlahTerjual.toString() ?? '');
    _tanggalTransaksiController =
        TextEditingController(text: widget.transaction?.tanggalTransaksi ?? '');

    // Fetch the barang list
    _fetchBarangList();
  }

  @override
  void dispose() {
    _stockController.dispose();
    _jumlahTerjualController.dispose();
    _tanggalTransaksiController.dispose();
    super.dispose();
  }

  Future<int> _fetchStockForBarang(int idBarang) async {
    try {
      // print(idBarang);
      final stock = await BarangService().getStockForBarang(idBarang);
      print(stock);
      return stock;
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load stock data')));
      return 0;
    }
  }

  Future<void> _fetchBarangList() async {
    try {
      final barangList =
          await BarangService().getBarangList(); // Fetch the list from service
      setState(() {
        _barangList = barangList;
        if (barangList.isNotEmpty) {
          // Set the selected barang id if editing
          _selectedBarangId =
              widget.transaction?.idBarang ?? barangList.first.idBarang;
        }
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load barang list')));
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final stock = int.parse(_stockController.text);
      final jumlahTerjual = int.parse(_jumlahTerjualController.text);
      final tanggalTransaksi = _tanggalTransaksiController.text;

      final selectedBarang = _barangList
          .firstWhere((barang) => barang.idBarang == _selectedBarangId);

      final newTransaction = ModelTransaction(
        idTransaksi: widget.transaction?.idTransaksi ?? 0,
        idBarang: selectedBarang.idBarang,
        stock: stock,
        jumlahTerjual: jumlahTerjual,
        tanggalTransaksi: tanggalTransaksi,
        namaBarang: selectedBarang.namaBarang,
        jenisBarang: selectedBarang.jenisBarang,
      );

      try {
        if (widget.isEditing) {
          await TransactionService().updateTransaction(newTransaction);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Transaction updated successfully')));
        } else {
          await TransactionService().createTransaction(newTransaction);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Transaction created successfully')));
        }

        Navigator.pop(context,
            newTransaction); // Return to the previous screen with a success flag
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedBarangId,
                decoration: InputDecoration(labelText: 'Nama Barang'),
                items: _barangList.map((barang) {
                  return DropdownMenuItem<int>(
                    value: barang.idBarang,
                    child: Text(barang.namaBarang),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedBarangId = value;
                  });
                  print(value);
                  final stock = await _fetchStockForBarang(value!);
                  _stockController.text = stock.toString();
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a barang';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jumlahTerjualController,
                decoration: InputDecoration(labelText: 'Jumlah Terjual'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter jumlah terjual';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tanggalTransaksiController,
                decoration: InputDecoration(labelText: 'Tanggal Transaksi'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a transaction date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.isEditing ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _tanggalTransaksiController.text =
            picked.toIso8601String().substring(0, 10);
      });
    }
  }
}
