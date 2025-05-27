import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';

import '../database/db_helper.dart';
import 'login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> filteredData = [];
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final db = await DBHelper.initDb();

    String whereClause = '';
    List<String> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'tanggal_masuk BETWEEN ? AND ?';
      whereArgs = [
        DateFormat('dd-MM-yyyy').format(startDate!),
        DateFormat('dd-MM-yyyy').format(endDate!)
      ];
    }

    final data = await db.query(
      'tamu',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );

    setState(() {
      allData = data;
      applyFilter();
    });
  }

  void applyFilter() {
    setState(() {
      filteredData = allData.where((item) {
        final q = searchQuery.toLowerCase();
        return item['nama'].toString().toLowerCase().contains(q) ||
            item['identitas'].toString().toLowerCase().contains(q) ||
            item['perusahaan'].toString().toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      await fetchData();
    }
  }

  Future<void> exportToExcel() async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Data Tamu'];

    sheet.appendRow([
      'Nama',
      'No. Telepon',
      'Identitas',
      'No. Kendaraan',
      'Perusahaan',
      'Bertemu Dengan',
      'Keperluan',
      'Tanggal Masuk',
      'Jam Masuk',
      'Tanggal Keluar',
      'Jam Keluar',
    ]);

    for (var item in filteredData) {
      sheet.appendRow([
        item['nama'],
        item['no_telepon'],
        item['identitas'],
        item['no_kendaraan'],
        item['perusahaan'],
        item['bertemu_dengan'],
        item['keperluan'],
        item['tanggal_masuk'],
        item['jam_masuk'],
        item['tanggal_keluar'],
        item['jam_keluar'],
      ]);
    }

    final downloadsDir = Directory("${Platform.environment['USERPROFILE']}\\Downloads");
    final now = DateTime.now();
    final formattedDate = DateFormat('ddMMyyyy_HHmmss').format(now);
    final file = File('${downloadsDir.path}\\export_tamu_$formattedDate.xlsx');

    file.writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data berhasil diexport ke: ${file.path}")),
    );
  }

  Widget buildTable() {
    if (filteredData.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('No. Telepon')),
          DataColumn(label: Text('Identitas')),
          DataColumn(label: Text('No. Kendaraan')),
          DataColumn(label: Text('Perusahaan')),
          DataColumn(label: Text('Bertemu')),
          DataColumn(label: Text('Keperluan')),
          DataColumn(label: Text('Tgl Masuk')),
          DataColumn(label: Text('Jam Masuk')),
          DataColumn(label: Text('Tgl Keluar')),
          DataColumn(label: Text('Jam Keluar')),
        ],
        rows: filteredData.map((item) {
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
          ]);
        }).toList(),
      ),
    );
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    String filterText = (startDate != null && endDate != null)
        ? '${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}'
        : 'Semua Tanggal';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Buku Tamu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari tamu (Nama / Identitas / Perusahaan)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  applyFilter();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: selectDateRange,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Filter Tanggal Masuk'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: filteredData.isEmpty ? null : exportToExcel,
                  icon: const Icon(Icons.download),
                  label: const Text('Export ke Excel'),
                ),
              ],
            ),
          ),
          Text('Filter: $filterText'),
          const SizedBox(height: 10),
          Expanded(child: buildTable()),
        ],
      ),
    );
  }
}
