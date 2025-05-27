import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'login_page.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});


  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController noTeleponController = TextEditingController();
  final TextEditingController identitasController = TextEditingController();
  final TextEditingController noKendaraanController = TextEditingController();
  final TextEditingController perusahaanController = TextEditingController();
  final TextEditingController bertemuDenganController = TextEditingController();
  final TextEditingController keperluanController = TextEditingController();
  final TextEditingController tanggalMasukController = TextEditingController();
  final TextEditingController jamMasukController = TextEditingController();
  final TextEditingController tanggalKeluarController = TextEditingController();
  final TextEditingController jamKeluarController = TextEditingController();

  List<Map<String, dynamic>> tamuList = [];
  DateTimeRange? filterRange;
  int? editingId;

  @override
  void initState() {
    super.initState();
    fetchDataForToday();
  }

  Future<void> fetchDataForToday() async {
    final now = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(now);
    fetchData(today, today);
  }

  Future<void> fetchData(String fromDate, String toDate) async {
    final db = await DBHelper.initDb();
    final data = await db.rawQuery(
      'SELECT * FROM tamu WHERE tanggal_masuk BETWEEN ? AND ? ORDER BY id DESC',
      [fromDate, toDate],
    );
    setState(() {
      tamuList = data;
    });
  }

  Future<void> simpanAtauUpdateData() async {
    if (_formKey.currentState!.validate()) {
      final db = await DBHelper.initDb();

      final data = {
        'nama': namaController.text,
        'no_telepon': noTeleponController.text,
        'identitas': identitasController.text,
        'no_kendaraan': noKendaraanController.text,
        'perusahaan': perusahaanController.text,
        'bertemu_dengan': bertemuDenganController.text,
        'keperluan': keperluanController.text,
        'tanggal_masuk': tanggalMasukController.text,
        'jam_masuk': jamMasukController.text,
        'tanggal_keluar': tanggalKeluarController.text,
        'jam_keluar': jamKeluarController.text,
      };

      if (editingId == null) {
        await db.insert('tamu', data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan')),
        );
      } else {
        await db.update('tamu', data, where: 'id = ?', whereArgs: [editingId]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui')),
        );
        editingId = null;
      }

      fetchDataForToday();
      _formKey.currentState!.reset();
      clearControllers();
    }
  }

  void clearControllers() {
    namaController.clear();
    noTeleponController.clear();
    identitasController.clear();
    noKendaraanController.clear();
    perusahaanController.clear();
    bertemuDenganController.clear();
    keperluanController.clear();
    tanggalMasukController.clear();
    jamMasukController.clear();
    tanggalKeluarController.clear();
    jamKeluarController.clear();
  }

  Future<void> pilihTanggal() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      final start = DateFormat('dd-MM-yyyy').format(result.start);
      final end = DateFormat('dd-MM-yyyy').format(result.end);
      filterRange = result;
      fetchData(start, end);
    }
  }

  Future<void> hapusData(int id) async {
    final db = await DBHelper.initDb();
    await db.delete('tamu', where: 'id = ?', whereArgs: [id]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil dihapus')),
    );
    fetchDataForToday();
  }


  void editData(Map<String, dynamic> item) {
    setState(() {
      editingId = item['id'];
      namaController.text = item['nama'] ?? '';
      noTeleponController.text = item['no_telepon'] ?? '';
      identitasController.text = item['identitas'] ?? '';
      noKendaraanController.text = item['no_kendaraan'] ?? '';
      perusahaanController.text = item['perusahaan'] ?? '';
      bertemuDenganController.text = item['bertemu_dengan'] ?? '';
      keperluanController.text = item['keperluan'] ?? '';
      tanggalMasukController.text = item['tanggal_masuk'] ?? '';
      jamMasukController.text = item['jam_masuk'] ?? '';
      tanggalKeluarController.text = item['tanggal_keluar'] ?? '';
      jamKeluarController.text = item['jam_keluar'] ?? '';
    });
  }

  void logout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Widget buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = DateFormat('dd-MM-yyyy').format(picked);
        }
      },
    );
  }

  Widget buildTimeField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          controller.text = picked.format(context);
        }
      },
    );
  }

  Widget buildDateFieldWithValidator(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = DateFormat('dd-MM-yyyy').format(picked);
        }
      },
    );
  }

  Widget buildTimeFieldWithValidator(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          controller.text = picked.format(context);
        }
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Buku Tamu'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: noTeleponController,
                    decoration: const InputDecoration(labelText: 'No Telepon'),
                    keyboardType: TextInputType.phone,
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: identitasController,
                    decoration: const InputDecoration(labelText: 'Identitas'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: noKendaraanController,
                    decoration: const InputDecoration(labelText: 'No Kendaraan'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: perusahaanController,
                    decoration: const InputDecoration(labelText: 'Perusahaan'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: bertemuDenganController,
                    decoration: const InputDecoration(labelText: 'Bertemu Dengan'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: keperluanController,
                    decoration: const InputDecoration(labelText: 'Keperluan'),
                    validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  buildDateFieldWithValidator('Tanggal Masuk', tanggalMasukController),
                  buildTimeFieldWithValidator('Jam Masuk', jamMasukController),
                  buildDateField('Tanggal Keluar', tanggalKeluarController),
                  buildTimeField('Jam Keluar', jamKeluarController),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: simpanAtauUpdateData,
                    child: Text(editingId == null ? 'Simpan' : 'Update'),
                  ),
                  if (editingId != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          editingId = null;
                          _formKey.currentState?.reset();
                          clearControllers();
                        });
                      },
                      child: const Text('Tambah Data'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: pilihTanggal,
                  icon: const Icon(Icons.date_range),
                  label: const Text('Filter Tanggal'),
                ),
                Text(filterRange == null
                    ? 'Filter: Hari ini'
                    : 'Filter: ${DateFormat('dd/MM/yyyy').format(filterRange!.start)} - ${DateFormat('dd/MM/yyyy').format(filterRange!.end)}')
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('No Telepon')),
                  DataColumn(label: Text('Identitas')),
                  DataColumn(label: Text('No Kendaraan')),
                  DataColumn(label: Text('Perusahaan')),
                  DataColumn(label: Text('Bertemu Dengan')),
                  DataColumn(label: Text('Keperluan')),
                  DataColumn(label: Text('Tanggal Masuk')),
                  DataColumn(label: Text('Jam Masuk')),
                  DataColumn(label: Text('Tanggal Keluar')),
                  DataColumn(label: Text('Jam Keluar')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: tamuList.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item['nama'] ?? '')),
                    DataCell(Text(item['no_telepon'] ?? '')),
                    DataCell(Text(item['identitas'] ?? '')),
                    DataCell(Text(item['no_kendaraan'] ?? '')),
                    DataCell(Text(item['perusahaan'] ?? '')),
                    DataCell(Text(item['bertemu_dengan'] ?? '')),
                    DataCell(Text(item['keperluan'] ?? '')),
                    DataCell(Text(item['tanggal_masuk'] ?? '')),
                    DataCell(Text(item['jam_masuk'] ?? '')),
                    DataCell(Text(item['tanggal_keluar'] ?? '')),
                    DataCell(Text(item['jam_keluar'] ?? '')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editData(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Hapus'),
                                content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              hapusData(item['id']);
                            }
                          },
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}