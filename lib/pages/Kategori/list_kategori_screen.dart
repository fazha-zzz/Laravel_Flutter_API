import 'package:auth/models/kategori_model.dart';
import 'package:auth/pages/Kategori/create_kategori.dart';
import 'package:auth/pages/Kategori/edit_Kategori_screen.dart';
import 'package:auth/services/kategori_service.dart';

import 'package:flutter/material.dart';

class ListKategoriScreen extends StatefulWidget {
  const ListKategoriScreen({super.key});

  @override
  State<ListKategoriScreen> createState() => _ListKategoriScreenState();
}

class _ListKategoriScreenState extends State<ListKategoriScreen> {
  late Future<KategoriModel> _futureKategoris;

  @override
  void initState() {
    super.initState();
    _futureKategoris = KategoriService.listKategoris();
  }

  void _refreshKategoris() {
    setState(() {
      _futureKategoris = KategoriService.listKategoris();
    });
  }

 

  void _deleteKategori(int id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus kategori "$nama"?'),
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

    if (confirm != true) return;

    final success = await KategoriService.deleteKategori(id);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
        _refreshKategoris();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus kategori')),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Kategori'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshKategoris,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateKategoriScreen()),
              );
              if (result == true) _refreshKategoris();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Kategori',
          ),
        ],
      ),
      body: FutureBuilder<KategoriModel>(
        future: _futureKategoris,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshKategoris,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final kategoriList = snapshot.data?.data ?? [];

          if (kategoriList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada kategori',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah kategori baru',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: kategoriList.length,
            itemBuilder: (context, index) {
              final kategori = kategoriList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    kategori.nama ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'ID: ${kategori.id}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditKategoriScreen(kategori: kategori),
                            ),
                          );
                          if (result == true) _refreshKategoris();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Hapus',
                        onPressed: () => _deleteKategori(
                          kategori.id ?? 0,
                          kategori.nama ?? '',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

