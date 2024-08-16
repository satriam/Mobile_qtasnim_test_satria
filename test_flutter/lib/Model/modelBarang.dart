class Modelbarang {
  final int idBarang;
  final String namaBarang;
  final String jenisBarang;
  final String StockAwal;

  Modelbarang({
    required this.idBarang,
    required this.namaBarang,
    required this.jenisBarang,
    required this.StockAwal,
  });

  factory Modelbarang.fromJson(Map<String, dynamic> json) {
    return Modelbarang(
      idBarang: json['IdBarang'] is int
          ? json['IdBarang']
          : int.parse(json['IdBarang']),
      namaBarang: json['NamaBarang'],
      jenisBarang: json['JenisBarang'],
      StockAwal: json['StockAwal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdBarang': idBarang,
      'NamaBarang': namaBarang,
      'JenisBarang': jenisBarang,
      'StockAwal': StockAwal,
    };
  }
}
