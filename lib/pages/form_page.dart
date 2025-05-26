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
  final TextEditingController nikController = TextEditingController();
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
    final today = DateFormat('yyyy-MM-dd').format(now);
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
        'nik': nikController.text,
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
    nikController.clear();
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
      final start = DateFormat('yyyy-MM-dd').format(result.start);
      final end = DateFormat('yyyy-MM-dd').format(result.end);
      filterRange = result;
      fetchData(start, end);
    }
  }

  void editData(Map<String, dynamic> item) {
    setState(() {
      editingId = item['id'];
      namaController.text = item['nama'] ?? '';
      noTeleponController.text = item['no_telepon'] ?? '';
      nikController.text = item['nik'] ?? '';
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
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                      controller: namaController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                      validator: (val) =>
                          val!.isEmpty ? 'Wajib diisi' : null),
                  TextFormField(
                      controller: noTeleponController,
                      decoration: const InputDecoration(labelText: 'No Telepon'),
                      keyboardType: TextInputType.phone),
                  TextFormField(
                      controller: nikController,
                      decoration: const InputDecoration(labelText: 'NIK')),
                  TextFormField(
                      controller: noKendaraanController,
                      decoration: const InputDecoration(labelText: 'No Kendaraan')),
                  TextFormField(
                      controller: perusahaanController,
                      decoration: const InputDecoration(labelText: 'Perusahaan')),
                  TextFormField(
                      controller: bertemuDenganController,
                      decoration: const InputDecoration(labelText: 'Bertemu Dengan')),
                  TextFormField(
                      controller: keperluanController,
                      decoration: const InputDecoration(labelText: 'Keperluan')),
                  buildDateField('Tanggal Masuk', tanggalMasukController),
                  buildTimeField('Jam Masuk', jamMasukController),
                  buildDateField('Tanggal Keluar', tanggalKeluarController),
                  buildTimeField('Jam Keluar', jamKeluarController),
                  const SizedBox(height: 20),
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
            DataTable(
              columns: const [
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Tanggal Masuk')),
                DataColumn(label: Text('Jam Masuk')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: tamuList.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item['nama'] ?? '')),
                  DataCell(Text(item['tanggal_masuk'] ?? '')),
                  DataCell(Text(item['jam_masuk'] ?? '')),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => editData(item),
                  )),
                ]);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
