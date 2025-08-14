import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/peminjaman_service.dart';
import '../../services/auth_service.dart';
import '../../services/buku_service.dart';
import '../../models/buku_model.dart';

class PeminjamanCreateScreen extends StatefulWidget {
  final Buku? selectedBuku; // Add parameter to pre-select a book
  const PeminjamanCreateScreen({Key? key, this.selectedBuku}) : super(key: key);

  @override
  State<PeminjamanCreateScreen> createState() => _PeminjamanCreateScreenState();
}

class _PeminjamanCreateScreenState extends State<PeminjamanCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final PeminjamanService _peminjamanService = PeminjamanService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoadingBuku = true;

  // User data
  Map<String, dynamic>? _currentUser;
  int? _userId;

  // Buku data
  List<Buku> _bukuList = [];
  Buku? _selectedBuku;

  // Controllers
  final TextEditingController _stokDipinjamController = TextEditingController(
    text: '1',
  );
  final TextEditingController _tanggalPinjamController =
      TextEditingController();
  final TextEditingController _tenggatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setDefaultDates();
  }

  Future<void> _initializeData() async {
    await _loadCurrentUser();
    await _loadBukuList();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getProfile();
      setState(() {
        _currentUser = user;
        _userId = user!['id']; // Assuming the user ID field is 'id'
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBukuList() async {
    try {
      setState(() {
        _isLoadingBuku = true;
      });

      final bukus = await BukuService.fetchBukus();
      setState(() {
        _bukuList = bukus;

        // If there's a pre-selected book, set it as selected
        if (widget.selectedBuku != null) {
          _selectedBuku = _bukuList.firstWhere(
            (buku) => buku.id == widget.selectedBuku!.id,
            orElse: () => widget.selectedBuku!,
          );
        }

        _isLoadingBuku = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBuku = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data buku: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setDefaultDates() {
    // Set default tanggal_pinjam to today
    final today = DateTime.now();
    _tanggalPinjamController.text =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Set default tenggat to 7 days from today
    final defaultTenggat = today.add(const Duration(days: 7));
    _tenggatController.text =
        '${defaultTenggat.year}-${defaultTenggat.month.toString().padLeft(2, '0')}-${defaultTenggat.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stokDipinjamController.dispose();
    _tanggalPinjamController.dispose();
    _tenggatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? firstDate,
  }) async {
    DateTime initialDate = DateTime.now();

    // If controller has a date, use it as initial date
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data user tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedBuku == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih buku terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'user_id': _userId!,
        'buku_id': _selectedBuku!.id,
        'stok_dipinjam': int.parse(_stokDipinjamController.text),
        'tanggal_pinjam': _tanggalPinjamController.text,
        'tenggat': _tenggatController.text,
        'status': 'dipinjam',
      };

      await _peminjamanService.createPeminjaman(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil dibuat'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat peminjaman: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _selectedBuku = null;
    _stokDipinjamController.text = '1';
    _setDefaultDates();
    _formKey.currentState?.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Peminjaman Baru'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.selectedBuku != null
                                ? 'Peminjaman untuk buku "${widget.selectedBuku!.judul}" atas nama ${_currentUser?['name'] ?? 'Loading...'}'
                                : 'Peminjaman akan dibuat atas nama ${_currentUser?['name'] ?? 'Loading...'}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Form Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Peminjaman',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User Info Display
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Peminjam',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _currentUser?['name'] ?? 'Loading...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _currentUser?['email'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Buku Dropdown
                        DropdownButtonFormField<Buku>(
                          value: _selectedBuku,
                          decoration: InputDecoration(
                            labelText: 'Pilih Buku *',
                            hintText: _isLoadingBuku
                                ? 'Memuat data buku...'
                                : 'Pilih buku yang akan dipinjam',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.book),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          items: _isLoadingBuku
                              ? []
                              : _bukuList.map((Buku buku) {
                                  return DropdownMenuItem<Buku>(
                                    value: buku,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          buku.judul ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          onChanged: _isLoadingBuku
                              ? null
                              : (Buku? newValue) {
                                  setState(() {
                                    _selectedBuku = newValue;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Pilih buku yang akan dipinjam';
                            }
                            return null;
                          },
                          isExpanded: true,
                        ),
                        const SizedBox(height: 16),

                        // Stok Dipinjam Field
                        TextFormField(
                          controller: _stokDipinjamController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Dipinjam *',
                            hintText: 'Masukkan jumlah buku yang dipinjam',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.numbers),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jumlah dipinjam harus diisi';
                            }
                            final qty = int.tryParse(value);
                            if (qty == null || qty <= 0) {
                              return 'Jumlah dipinjam harus berupa angka positif';
                            }
                            if (_selectedBuku != null &&
                               qty > (_selectedBuku?.stok ?? 0)) {
                              return 'Jumlah melebihi stok tersedia (${_selectedBuku!.stok})';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tanggal Pinjam Field
                        TextFormField(
                          controller: _tanggalPinjamController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Pinjam *',
                            hintText: 'Pilih tanggal peminjaman',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _tanggalPinjamController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal pinjam harus dipilih';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tenggat Field
                        TextFormField(
                          controller: _tenggatController,
                          decoration: InputDecoration(
                            labelText: 'Tenggat Pengembalian *',
                            hintText: 'Pilih batas waktu pengembalian',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.event),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          readOnly: true,
                          onTap: () {
                            DateTime? minDate;
                            if (_tanggalPinjamController.text.isNotEmpty) {
                              try {
                                minDate = DateTime.parse(
                                  _tanggalPinjamController.text,
                                ).add(const Duration(days: 1));
                              } catch (e) {
                                minDate = DateTime.now().add(
                                  const Duration(days: 1),
                                );
                              }
                            }
                            _selectDate(
                              context,
                              _tenggatController,
                              firstDate: minDate,
                            );
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tenggat pengembalian harus dipilih';
                            }
                            // Validate that tenggat is after tanggal_pinjam
                            if (_tanggalPinjamController.text.isNotEmpty) {
                              try {
                                final tanggalPinjam = DateTime.parse(
                                  _tanggalPinjamController.text,
                                );
                                final tenggat = DateTime.parse(value);
                                if (tenggat.isBefore(tanggalPinjam) ||
                                    tenggat.isAtSameMomentAs(tanggalPinjam)) {
                                  return 'Tenggat harus setelah tanggal pinjam';
                                }
                              } catch (e) {
                                return 'Format tanggal tidak valid';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Status Display (Read-only)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Status Peminjaman',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'DIPINJAM',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isLoadingBuku)
                            ? null
                            : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Memproses...'),
                                ],
                              )
                            : const Text(
                                'Buat Peminjaman',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
