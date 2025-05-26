import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {
    'nama': TextEditingController(),
    'no_telepon': TextEditingController(),
    'nik': TextEditingController(),
    'no_kendaraan': TextEditingController(),
    'perusahaan': TextEditingController(),
    'bertemu_dengan': TextEditingController(),
    'keperluan': TextEditingController(),
    'tanggal_masuk': TextEditingController(),
    'jam_masuk': TextEditingController(),
    'tanggal_keluar': TextEditingController(),
    'jam_keluar': TextEditingController(),
  };

  Future<void> simpanData() async {
    if (formKey.currentState!.validate()) {
      final db = await DBHelper.initDb();
      await db.insert('tamu', {
        for (var entry in controllers.entries) entry.key: entry.value.text
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan')),
      );

      formKey.currentState!.reset();
      controllers.forEach((_, controller) => controller.clear());
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildTextField(String label, String key, {bool isDate = false, bool isTime = false}) {
    return TextFormField(
      controller: controllers[key],
      decoration: InputDecoration(labelText: label),
      readOnly: isDate || isTime,
      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
      onTap: () async {
        if (isDate) {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );
          if (picked != null) {
            controllers[key]!.text = picked.toIso8601String().split('T')[0];
          }
        } else if (isTime) {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            controllers[key]!.text = picked.format(context);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Buku Tamu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              buildTextField('Nama', 'nama'),
              buildTextField('No. Telepon', 'no_telepon'),
              buildTextField('NIK', 'nik'),
              buildTextField('No. Kendaraan', 'no_kendaraan'),
              buildTextField('Perusahaan', 'perusahaan'),
              buildTextField('Bertemu Dengan', 'bertemu_dengan'),
              buildTextField('Keperluan', 'keperluan'),
              buildTextField('Tanggal Masuk', 'tanggal_masuk', isDate: true),
              buildTextField('Jam Masuk', 'jam_masuk', isTime: true),
              buildTextField('Tanggal Keluar', 'tanggal_keluar', isDate: true),
              buildTextField('Jam Keluar', 'jam_keluar', isTime: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: simpanData,
                child: const Text('Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
