import 'package:flutter/material.dart';
import 'package:test_flutter/Model/modelBarang.dart';
import 'package:test_flutter/Service/serviceBarang.dart';

class BarangFormScreen extends StatefulWidget {
  final Modelbarang? barang; // null when creating a new entry
  final bool isEditing;

  BarangFormScreen({this.barang}) : isEditing = barang != null;

  @override
  _BarangFormScreenState createState() => _BarangFormScreenState();
}

class _BarangFormScreenState extends State<BarangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _jenisController;
  late TextEditingController _StockAwalController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    _namaController =
        TextEditingController(text: widget.barang?.namaBarang ?? '');
    _jenisController =
        TextEditingController(text: widget.barang?.jenisBarang ?? '');
    _StockAwalController =
        TextEditingController(text: widget.barang?.StockAwal ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jenisController.dispose();
    _StockAwalController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final namaBarang = _namaController.text;
      final jenisBarang = _jenisController.text;
      final StockAwal = _StockAwalController.text;

      final Modelbarang newBarang = Modelbarang(
        idBarang:
            widget.barang?.idBarang ?? 0, // 0 or any temporary id for creation
        namaBarang: namaBarang,
        jenisBarang: jenisBarang,
        StockAwal: StockAwal,
      );

      if (widget.isEditing) {
        await BarangService().updateBarang(newBarang);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Barang updated successfully')));
      } else {
        await BarangService().createBarang(newBarang);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Barang created successfully')));
      }

      Navigator.pop(context,
          newBarang); // Return to the previous screen with a success flag
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Barang' : 'Add Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Barang'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the barang';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _jenisController,
                decoration: InputDecoration(labelText: 'Jenis Barang'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the type of the barang';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _StockAwalController,
                decoration: InputDecoration(labelText: 'Stock Awal'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Stock Awal';
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
}
