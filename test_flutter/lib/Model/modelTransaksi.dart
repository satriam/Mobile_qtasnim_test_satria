import 'dart:convert';

class ModelTransaction {
  final int idTransaksi;
  final int idBarang;
  final int stock;
  final int jumlahTerjual;
  final String tanggalTransaksi;
  final String namaBarang;
  final String jenisBarang;

  ModelTransaction({
    required this.idTransaksi,
    required this.idBarang,
    required this.stock,
    required this.jumlahTerjual,
    required this.tanggalTransaksi,
    required this.namaBarang,
    required this.jenisBarang,
  });

  factory ModelTransaction.fromJson(Map<String, dynamic> json) {
    return ModelTransaction(
      idTransaksi: json['IdTransaksi'] is int
          ? json['IdTransaksi']
          : int.parse(json['IdTransaksi']),
      idBarang: int.tryParse(json['IdBarang']) ?? 0,
      stock: int.tryParse(json['Stock']) ?? 0,
      jumlahTerjual: int.tryParse(json['JumlahTerjual']) ?? 0,
      tanggalTransaksi: json['TanggalTransaksi'] ?? '',
      namaBarang: json['NamaBarang'] ?? '',
      jenisBarang: json['JenisBarang'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'IdTransaksi': idTransaksi,
        'IdBarang': idBarang,
        'Stock': stock,
        'JumlahTerjual': jumlahTerjual,
        'TanggalTransaksi': tanggalTransaksi,
        'NamaBarang': namaBarang,
        'JenisBarang': jenisBarang,
      };
}
