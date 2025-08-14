import 'package:auth/pages/peminjaman/edit_peminjaman.dart';
import 'package:flutter/material.dart';
import '../../models/peminjaman_model.dart';
import '../../services/peminjaman_service.dart';


class ListDetailScreen extends StatefulWidget {
  final int peminjamanId;

  const ListDetailScreen({Key? key, required this.peminjamanId})
    : super(key: key);

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final PeminjamanService _peminjamanService = PeminjamanService();
  late Future<PeminjamanModel> _peminjamanFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadPeminjaman();
  }

  void _loadPeminjaman() {
    _peminjamanFuture = _peminjamanService.getPeminjamanById(
      widget.peminjamanId,
    );
  }

  Future<void> _deletePeminjaman() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Peminjaman'),
        content: const Text('Are you sure you want to delete this peminjaman?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await _peminjamanService.deletePeminjaman(widget.peminjamanId);
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete peminjaman: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<PeminjamanModel>(
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
                    onPressed: () {
                      setState(() {
                        _loadPeminjaman();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final peminjaman = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('ID', peminjaman.id.toString()),
                          _buildDetailRow(
                            'User',
                            peminjaman.user?.name ??
                                'User ID: ${peminjaman.userId}',
                          ),
                          _buildDetailRow(
                            'Buku',
                            peminjaman.buku?.judul ??
                                'Buku ID: ${peminjaman.bukuId}',
                          ),
                          _buildDetailRow(
                            'Stok Dipinjam',
                            peminjaman.stokDipinjam.toString(),
                          ),
                          _buildDetailRow(
                            'Tanggal Pinjam',
                            peminjaman.tanggalPinjam,
                          ),
                          _buildDetailRow('Tenggat', peminjaman.tenggat),
                          _buildDetailRow(
                            'Tanggal Pengembalian',
                            peminjaman.tanggalPengembalian ??
                                'Belum dikembalikan',
                          ),
                          _buildDetailRow(
                            'Status',
                            peminjaman.status,
                            statusColor:
                                peminjaman.status.toLowerCase() == 'dipinjam'
                                ? Colors.orange
                                : Colors.green,
                          ),
                          _buildDetailRow('Created At', peminjaman.createdAt),
                          _buildDetailRow('Updated At', peminjaman.updatedAt),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDeleting
                              ? null
                              : () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListEditScreen(
                                        peminjaman: peminjaman,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {
                                      _loadPeminjaman();
                                    });
                                  }
                                },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDeleting ? null : _deletePeminjaman,
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.delete),
                          label: Text(_isDeleting ? 'Deleting...' : 'Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: statusColor,
                fontWeight: statusColor != null ? FontWeight.w500 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
