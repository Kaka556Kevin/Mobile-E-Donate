class FundRecord {
  int? key;
  String penerima;
  num uangKeluar;
  String donationId;

  FundRecord({
    this.key,
    required this.penerima,
    required this.uangKeluar,
    required this.donationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'penerima': penerima,
      'uangKeluar': uangKeluar,
      'donationId': donationId,
    };
  }

  factory FundRecord.fromMap(Map<String, dynamic> map) {
    return FundRecord(
      key: map['key'] as int?,
      penerima: map['penerima'] as String,
      uangKeluar: map['uangKeluar'] as num,
      donationId: map['donationId'] as String,
    );
  }
}
