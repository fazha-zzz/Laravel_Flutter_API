import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:auth/models/buku_model.dart';
import 'package:auth/services/buku_service.dart';
import 'package:auth/services/kategori_service.dart';
import 'package:auth/models/kategori_model.dart';

class BukuEditScreen extends StatefulWidget {
  final Buku buku;

  const BukuEditScreen({super.key, required this.buku});

  @override
  State<BukuEditScreen> createState() => _BukuEditScreenState();
}

class _BukuEditScreenState extends State<BukuEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _penulisController;
  late final TextEditingController _penerbitController;
  late final TextEditingController _tahunController;
  late final TextEditingController _stokController;

  Uint8List? _fotoBytes;
  String? _fotoName;
  bool _isLoading = false;
  bool _isLoadingKategori = true;
  bool _fotoChanged = false;

  List<DataKategori> _kategoris = [];
  int? _selectedKategoriId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadKategoris();
  }

  void _initializeControllers() {
    _judulController = TextEditingController(text: widget.buku.judul);
    _penulisController = TextEditingController(text: widget.buku.penulis);
    _penerbitController = TextEditingController(text: widget.buku.penerbit);
    _tahunController = TextEditingController(
      text: widget.buku.tahunTerbit.toString(),
    );
    _stokController = TextEditingController(text: widget.buku.stok.toString());
    // Get kategori ID from the kategori object
    _selectedKategoriId = widget.buku.kategori?.id;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    _tahunController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _loadKategoris() async {
    setState(() => _isLoadingKategori = true);
    try {
      final data = await KategoriService.fetchKategoris();
      if (mounted) {
        setState(() {
          _kategoris = data;
          _isLoadingKategori = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingKategori = false);
        if (e.toString().contains('Token tidak valid')) {
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat kategori: $e"),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: _loadKategoris,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          setState(() {
            _fotoBytes = bytes;
            _fotoName = picked.name;
            _fotoChanged = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil gambar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua field yang wajib diisi"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon pilih kategori buku"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await BukuService.updateBuku(
        id: widget.buku.id,
        judul: _judulController.text.trim(),
        penulis: _penulisController.text.trim(),
        penerbit: _penerbitController.text.trim(),
        tahunTerbit: int.tryParse(_tahunController.text) ?? DateTime.now().year,
        stok: int.tryParse(_stokController.text) ?? 0,
        kategoriId: _selectedKategoriId!,
        // Perbaiki sintaks di sini - hapus * dan gunakan kondisional yang benar
        fotoBytes: _fotoChanged ? _fotoBytes : null,
        fotoName: _fotoChanged ? (_fotoName ?? 'foto.jpg') : null,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Buku berhasil diperbarui"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal memperbarui buku. Silakan coba lagi."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Handle authentication errors
        if (e.toString().contains('Token tidak valid')) {
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildfotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("foto Buku", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: _fotoBytes != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _fotoBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _fotoBytes = null;
                                _fotoName = null;
                                _fotoChanged = true;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : widget.buku.foto != null && widget.buku.foto!.isNotEmpty
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'http://127.0.0.1:8000/storage/${widget.buku.foto}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _showImageSourceDialog,
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildPlaceholder(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            "Tap untuk mengubah foto buku",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Pilih foto Buku",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            "Tap untuk memilih dari galeri",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Buku"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        "Edit Informasi Buku",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Field Judul
                  TextFormField(
                    controller: _judulController,
                    decoration: const InputDecoration(
                      labelText: "Judul Buku *",
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul buku wajib diisi';
                      }
                      if (value.trim().length < 3) {
                        return 'Judul buku minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dropdown Kategori
                  _isLoadingKategori
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : DropdownButtonFormField<int>(
                          value: _selectedKategoriId,
                          decoration: const InputDecoration(
                            labelText: "Kategori *",
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text(
                                "Pilih kategori",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ..._kategoris.map((kategori) {
                              return DropdownMenuItem<int>(
                                value: kategori.id,
                                child: Text(kategori.nama.toString()),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedKategoriId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? "Kategori wajib dipilih" : null,
                        ),

                  const SizedBox(height: 16),

                  // Field Penulis
                  TextFormField(
                    controller: _penulisController,
                    decoration: const InputDecoration(
                      labelText: "Penulis *",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penulis wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field Penerbit
                  TextFormField(
                    controller: _penerbitController,
                    decoration: const InputDecoration(
                      labelText: "Penerbit *",
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penerbit wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field Tahun Terbit
                  TextFormField(
                    controller: _tahunController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Tahun Terbit *",
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Contoh: 2023",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tahun terbit wajib diisi';
                      }
                      final tahun = int.tryParse(value.trim());
                      if (tahun == null) {
                        return 'Tahun harus berupa angka';
                      }
                      if (tahun < 1900 || tahun > DateTime.now().year + 1) {
                        return 'Tahun tidak valid (1900-${DateTime.now().year + 1})';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field Stok
                  TextFormField(
                    controller: _stokController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Stok *",
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Jumlah buku yang tersedia",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Jumlah stok wajib diisi';
                      }
                      final stok = int.tryParse(value.trim());
                      if (stok == null) {
                        return 'Stok harus berupa angka';
                      }
                      if (stok < 0) {
                        return 'Stok tidak boleh negatif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section foto
                  _buildfotoSection(),
                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.update, color: Colors.white),
                            label: const Text(
                              "Perbarui Buku",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
