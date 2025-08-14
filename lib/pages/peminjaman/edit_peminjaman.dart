import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/peminjaman_model.dart';
import '../../services/peminjaman_service.dart';

class ListEditScreen extends StatefulWidget {
  final PeminjamanModel? peminjaman;

  const ListEditScreen({Key? key, this.peminjaman}) : super(key: key);

  @override
  State<ListEditScreen> createState() => _ListEditScreenState();
}

class _ListEditScreenState extends State<ListEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final PeminjamanService _peminjamanService = PeminjamanService();

  bool get _isEditMode => widget.peminjaman != null;
  bool _isLoading = false;

  // Controllers
  late TextEditingController _userIdController;
  late TextEditingController _bukuIdController;
  late TextEditingController _stokDipinjamController;
  late TextEditingController _tanggalPinjamController;
  late TextEditingController _tenggatController;

  String _selectedStatus = 'dipinjam';
  final List<String> _statusOptions = ['dipinjam', 'dikembalikan'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final peminjaman = widget.peminjaman;

    _userIdController = TextEditingController(
      text: peminjaman?.userId.toString() ?? '',
    );
    _bukuIdController = TextEditingController(
      text: peminjaman?.bukuId.toString() ?? '',
    );
    _stokDipinjamController = TextEditingController(
      text: peminjaman?.stokDipinjam.toString() ?? '',
    );
    _tanggalPinjamController = TextEditingController(
      text: peminjaman?.tanggalPinjam ?? '',
    );
    _tenggatController = TextEditingController(text: peminjaman?.tenggat ?? '');

    if (peminjaman != null) {
      _selectedStatus = peminjaman.status.toLowerCase();
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _bukuIdController.dispose();
    _stokDipinjamController.dispose();
    _tanggalPinjamController.dispose();
    _tenggatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'user_id': int.parse(_userIdController.text),
        'buku_id': int.parse(_bukuIdController.text),
        'stok_dipinjam': int.parse(_stokDipinjamController.text),
        'tanggal_pinjam': _tanggalPinjamController.text,
        'tenggat': _tenggatController.text,
        'status': _selectedStatus,
      };

      if (_isEditMode) {
        await _peminjamanService.updatePeminjaman(widget.peminjaman!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _peminjamanService.createPeminjaman(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peminjaman created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isEditMode ? 'update' : 'create'} peminjaman: $e',
            ),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Peminjaman' : 'Create Peminjaman'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode
                              ? 'Edit Peminjaman'
                              : 'Create New Peminjaman',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User ID Field
                        TextFormField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter user ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Buku ID Field
                        TextFormField(
                          controller: _bukuIdController,
                          decoration: const InputDecoration(
                            labelText: 'Buku ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.book),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter buku ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Stok Dipinjam Field
                        TextFormField(
                          controller: _stokDipinjamController,
                          decoration: const InputDecoration(
                            labelText: 'Stok Dipinjam',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter stok dipinjam';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) < 0) {
                              return 'Please enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tanggal Pinjam Field
                        TextFormField(
                          controller: _tanggalPinjamController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Pinjam',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _tanggalPinjamController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select tanggal pinjam';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tenggat Field
                        TextFormField(
                          controller: _tenggatController,
                          decoration: const InputDecoration(
                            labelText: 'Tenggat',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.event),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, _tenggatController),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select tenggat';
                            }
                            // Validate that tenggat is after tanggal_pinjam
                            if (_tanggalPinjamController.text.isNotEmpty) {
                              final tanggalPinjam = DateTime.parse(
                                _tanggalPinjamController.text,
                              );
                              final tenggat = DateTime.parse(value);
                              if (tenggat.isBefore(tanggalPinjam) ||
                                  tenggat.isAtSameMomentAs(tanggalPinjam)) {
                                return 'Tenggat must be after tanggal pinjam';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info),
                          ),
                          items: _statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStatus = newValue;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select status';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
                              Text('Processing...'),
                            ],
                          )
                        : Text(
                            _isEditMode
                                ? 'Update Peminjaman'
                                : 'Create Peminjaman',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
