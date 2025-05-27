class GuestModel {
  final String? id; // ubah dari int? ke String?
  final String nama;
  final String noTelepon;
  final String identitas;
  final String noKendaraan;
  final String perusahaan;
  final String bertemuDengan;
  final String keperluan;
  final String tanggalMasuk;
  final String jamMasuk;
  final String tanggalKeluar;
  final String jamKeluar;

  GuestModel({
    this.id,
    required this.nama,
    required this.noTelepon,
    required this.identitas,
    required this.noKendaraan,
    required this.perusahaan,
    required this.bertemuDengan,
    required this.keperluan,
    required this.tanggalMasuk,
    required this.jamMasuk,
    required this.tanggalKeluar,
    required this.jamKeluar,
  });

  factory GuestModel.fromMap(Map<String, dynamic> map) {
    return GuestModel(
      id: map['id']?.toString(), // pastikan id dikonversi ke String
      nama: map['nama'] ?? '',
      noTelepon: map['no_telepon'] ?? '',
      identitas: map['identitas'] ?? '',
      noKendaraan: map['no_kendaraan'] ?? '',
      perusahaan: map['perusahaan'] ?? '',
      bertemuDengan: map['bertemu_dengan'] ?? '',
      keperluan: map['keperluan'] ?? '',
      tanggalMasuk: map['tanggal_masuk'] ?? '',
      jamMasuk: map['jam_masuk'] ?? '',
      tanggalKeluar: map['tanggal_keluar'] ?? '',
      jamKeluar: map['jam_keluar'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'no_telepon': noTelepon,
      'identitas': identitas,
      'no_kendaraan': noKendaraan,
      'perusahaan': perusahaan,
      'bertemu_dengan': bertemuDengan,
      'keperluan': keperluan,
      'tanggal_masuk': tanggalMasuk,
      'jam_masuk': jamMasuk,
      'tanggal_keluar': tanggalKeluar,
      'jam_keluar': jamKeluar,
    };
  }
}
