import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_flutter/Model/modelBarang.dart';

class BarangService {
  final String baseUrl = 'http://localhost/api_test/api.php';

  Future<List<Modelbarang>> getBarangList({
    String sortBy = 'NamaBarang',
    String sortDir = 'asc',
    String searchQuery = '',
  }) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/barang?sort_by=$sortBy&sort_dir=$sortDir&search=$searchQuery'));

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          List<dynamic> data = json.decode(response.body);
          return data.map((json) => Modelbarang.fromJson(json)).toList();
        } catch (e) {
          throw Exception('Failed to parse response: ${e.toString()}');
        }
      } else {
        throw Exception('Response is empty');
      }
    } else {
      throw Exception('Failed to load barang');
    }
  }

  Future<int> getStockForBarang(int idBarang) async {
    final response = await http.get(Uri.parse('$baseUrl/barang/$idBarang'));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final item = data[0];
          if (item is Map<String, dynamic> && item.containsKey('StockAwal')) {
            return int.parse(item['StockAwal'].toString());
          } else {
            throw Exception('StockAwal not found in the data');
          }
        } else {
          throw Exception('No data available');
        }
      } catch (e) {
        throw Exception('Failed to parse stock data: ${e.toString()}');
      }
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  Future<void> createBarang(Modelbarang barang) async {
    final response = await http.post(
      Uri.parse('$baseUrl/barang'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(barang.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create barang');
    }
  }

  Future<void> updateBarang(Modelbarang barang) async {
    final response = await http.put(
      Uri.parse('$baseUrl/barang/${barang.idBarang}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(barang.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update barang');
    }
  }

  Future<void> deleteBarang(int idBarang) async {
    final response = await http.delete(Uri.parse('$baseUrl/barang/$idBarang'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete barang');
    }
  }
}
