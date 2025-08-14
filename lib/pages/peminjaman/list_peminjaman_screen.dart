import 'package:auth/pages/peminjaman/create_peminjaman.dart';
import 'package:auth/pages/peminjaman/detail_peminjaman.dart';
import 'package:flutter/material.dart';
import '../../models/peminjaman_model.dart';
import '../../services/peminjaman_service.dart';


class ListPeminjamanScreen extends StatefulWidget {
  const ListPeminjamanScreen({Key? key}) : super(key: key);

  @override
  State<ListPeminjamanScreen> createState() => _ListPeminjamanScreenState();
}

class _ListPeminjamanScreenState extends State<ListPeminjamanScreen> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  late Future<List<PeminjamanModel>> _peminjamanFuture;

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  void _loadPeminjaman() {
    _peminjamanFuture = _peminjamanService.getAllPeminjaman();
  }

  void _refreshData() {
    setState(() {
      _loadPeminjaman();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Peminjaman'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PeminjamanCreateScreen(),
                ),
              );
              if (result == true) {
                _refreshData();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PeminjamanModel>>(
        future: _peminjamanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, color: Colors.grey, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'No peminjaman found',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final peminjamanList = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: ListView.builder(
              itemCount: peminjamanList.length,
              itemBuilder: (context, index) {
                final peminjaman = peminjamanList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          peminjaman.status.toLowerCase() == 'dipinjam'
                          ? Colors.orange
                          : Colors.green,
                      child: Icon(
                        peminjaman.status.toLowerCase() == 'dipinjam'
                            ? Icons.book
                            : Icons.check,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      peminjaman.buku?.judul ?? 'Buku ID: ${peminjaman.bukuId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peminjam: ${peminjaman.user?.name ?? 'User ID: ${peminjaman.userId}'}',
                        ),
                        Text(
                          'Status: ${peminjaman.status}',
                          style: TextStyle(
                            color: peminjaman.status.toLowerCase() == 'dipinjam'
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ListDetailScreen(peminjamanId: peminjaman.id),
                        ),
                      );
                      if (result == true) {
                        _refreshData();
                      }
                    },
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
