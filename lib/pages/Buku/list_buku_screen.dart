import 'package:auth/pages/Buku/create_buku.dart';
import 'package:auth/pages/Buku/detail_buku_screen.dart';
import 'package:flutter/material.dart';
import 'package:auth/models/buku_model.dart';
import 'package:auth/services/buku_service.dart';

class BukuListScreen extends StatefulWidget {
  const BukuListScreen({super.key});

  @override
  State<BukuListScreen> createState() => _BukuListScreenState();
}

class _BukuListScreenState extends State<BukuListScreen> {
  late Future<List<Buku>> _futureBukus;

  @override
  void initState() {
    super.initState();
    _loadBukus();
  }

  void _loadBukus() {
    _futureBukus = BukuService.fetchBukus();
  }

  Future<void> _refreshBukus() async {
    setState(() => _loadBukus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BukuCreateScreen()),
              );
              _refreshBukus();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Buku',
          ),
        ],
      ),
      body: FutureBuilder<List<Buku>>(
        future: _futureBukus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final bukus = snapshot.data ?? [];

          if (bukus.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Tidak ada buku.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshBukus,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bukus.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final buku = bukus[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailBukuScreen(bukuId: buku.id),
                      ),
                    );
                    _refreshBukus();
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: buku.foto != null
                            ? Image.network(
                                'http://127.0.0.1:8000/storage/${buku.foto}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      title: Text(
                        buku.judul ?? "Judul tidak tersedia",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "Penulis: ${buku.penulis ?? 'Tidak tersedia'}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Stok: ${buku.stok ?? 0}",
                            style: TextStyle(
                              color: (buku.stok ?? 0) > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
