import 'package:auth/pages/Buku/edit_buku.dart';
import 'package:flutter/material.dart';
import 'package:auth/models/buku_model.dart';
// import 'package:auth/pages/peminjaman/peminjaman_create_screen.dart';
import 'package:auth/services/buku_service.dart';

class DetailBukuScreen extends StatefulWidget {
  final int bukuId;
  const DetailBukuScreen({Key? key, required this.bukuId}) : super(key: key);

  @override
  State<DetailBukuScreen> createState() => _DetailBukuScreenState();
}

class _DetailBukuScreenState extends State<DetailBukuScreen> {
  late Future<Buku> _futureBuku;

  @override
  void initState() {
    super.initState();
    _futureBuku = BukuService.showBuku(widget.bukuId);
  }

  // Method to refresh the book data
  void _refreshBuku() {
    setState(() {
      _futureBuku = BukuService.showBuku(widget.bukuId);
    });
  }

  // Method to navigate to edit screen
  void _navigateToEdit(Buku buku) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BukuEditScreen(buku: buku)),
    );

    // If edit was successful, refresh the detail view
    if (result == true) {
      _refreshBuku();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Buku berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Method to navigate to peminjaman create screen
  // void _navigateToPinjamBuku(Buku buku) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PeminjamanCreateScreen(
  //         selectedBuku: buku, // Pass the selected book to pre-fill the form
  //       ),
  //     ),
  //   );

  //   // If peminjaman was successful, refresh the book data to update stock
  //   if (result == true) {
  //     _refreshBuku();
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Peminjaman berhasil dibuat"),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
// Updated bagian build widget untuk detail buku
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Buku"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<Buku>(
            future: _futureBuku,
            builder: (context, snapshot) {
              return IconButton(
                onPressed: snapshot.hasData
                    ? () => _navigateToEdit(snapshot.data!)
                    : null,
                icon: const Icon(Icons.edit),
              );
            },
          ),
          IconButton(
            onPressed: () {
              _showDeleteDialog();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder<Buku>(
        future: _futureBuku,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshBuku,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Data buku tidak ditemukan"));
          }

          final buku = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // foto Buku
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: buku.foto != null
                          ? Image.network(
                              'http://127.0.0.1:8000/storage/${buku.foto}',
                              height: 250,
                              width: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Judul Buku - Updated to use getter
                Text(
                  buku.displayJudul,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Info Buku - Updated to use getters
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow("Penulis", buku.displayPenulis),
                        _buildInfoRow("Penerbit", buku.displayPenerbit),
                        _buildInfoRow(
                          "Tahun Terbit",
                          buku.displayTahunTerbit.toString(),
                        ),
                        _buildInfoRow(
                          "Kategori",
                          buku.kategori?.displayNama ?? 'Tidak tersedia',
                        ),
                        _buildInfoRow(
                          "Stok",
                          "${buku.displayStok} buku",
                          valueColor: buku.displayStok > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Additional Edit Button (Alternative placement)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEdit(buku),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Buku"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method untuk placeholder image
  Widget _buildPlaceholderImage() {
    return Container(
      height: 250,
      width: 180,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        size: 80,
        color: Colors.grey,
      ),
    );
  }
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) => AlertDialog(
        title: const Text(
          "Hapus Buku",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Yakin ingin menghapus buku ini? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => _deleteBuku(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBuku() async {
    // Close the confirmation dialog first
    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Menghapus buku..."),
          ],
        ),
      ),
    );

    try {
      final success = await BukuService.deleteBuku(widget.bukuId);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Buku berhasil dihapus"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Return to previous screen with refresh signal
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Buku tidak bisa dihapus karena masih ada yang meminjam.",
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      if (mounted) {
        // Handle specific errors
        String errorMessage = "Terjadi kesalahan saat menghapus buku";

        if (e.toString().contains('Token tidak valid')) {
          // Redirect to login if token is invalid
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        } else if (e.toString().contains('Network')) {
          errorMessage = "Koneksi internet bermasalah";
        } else if (e.toString().contains('404')) {
          errorMessage = "Buku tidak ditemukan";
        } else if (e.toString().contains('403')) {
          errorMessage = "Anda tidak memiliki izin untuk menghapus buku ini";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () => _showDeleteDialog(),
            ),
          ),
        );
      }
    }
  }
}
