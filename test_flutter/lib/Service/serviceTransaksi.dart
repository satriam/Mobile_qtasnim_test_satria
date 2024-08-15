import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_flutter/Model/modelTransaksi.dart';

class TransactionService {
  final String apiUrl = 'http://localhost/api_test/api.php';

  Future<List<ModelTransaction>> getTransactionList({
    String sortBy = 'NamaBarang',
    String sortDir = 'asc',
    String searchQuery = '',
  }) async {
    final response = await http.get(Uri.parse(
        '$apiUrl/transaksi?sort_by=$sortBy&sort_dir=$sortDir&search=$searchQuery'));
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        print(response.body);
        try {
          List<dynamic> data = json.decode(response.body);
          return data.map((json) => ModelTransaction.fromJson(json)).toList();
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

  Future<void> createTransaction(ModelTransaction transaction) async {
    final response = await http.post(
      Uri.parse('$apiUrl/transaksi'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create transaction');
    }
  }

  Future<void> updateTransaction(ModelTransaction transaction) async {
    final response = await http.put(
      Uri.parse('$apiUrl/transaksi/${transaction.idTransaksi}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(int transaksiID) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/transaksi/$transaksiID'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  }
}
