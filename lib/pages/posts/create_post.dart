import 'dart:typed_data';

import 'package:auth/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey= GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _status = 1;
  Uint8List? _imageBytes;
  String ? _imageName;
  bool _isLoading = false;
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery,
    imageQuality: 80,);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes =bytes;
        _imageName =image.name;
      });
    }
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await PostService.createPost(
      _titleController.text,
      _contentController.text,
      _status,
      _imageBytes,
      _imageName,
      );
      
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post Berhasil dibuat'), backgroundColor: Colors.green ),
        );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat post'), backgroundColor: Colors.red )
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('create post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration:  const InputDecoration(labelText: 'Judal Post'),
                validator: (v) => v == null || v.isEmpty? 'judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration:  const InputDecoration(labelText: 'Konten'),
                validator: (v) => v == null || v.isEmpty? 'konten tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _status,
                decoration:  const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value:1, child:  Text('published')),
                  DropdownMenuItem(value: 0, child: Text('draft')),
                ],
                onChanged: (v) => setState(()=> _status = v ?? 1),
                ),
                const SizedBox(height: 16),



                //image
                if (_imageBytes != null)
                ClipRRect(
                  child: Image.memory(_imageBytes!,
                      height: 200, fit: BoxFit.cover),
                ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: Text(
                    _imageBytes == null ? 'Pilih Gambar' : 'Ganti Gambar'),
              ),
              if (_imageBytes != null)
                TextButton.icon(
                  onPressed: () => setState(() {
                    _imageBytes = null;
                    _imageName = null;
                  }),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Hapus Gambar',
                      style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),


              // Submit
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_status == 1 ? 'Publish' : 'Simpan Draft'),
                ),
              ),

            ],
          )
          ),
          ),
    );
  }
}





