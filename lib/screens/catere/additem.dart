import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capp/utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  File? _image;

  Future<void> _saveItem() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (_nameCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty ||
        _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("All fields required")));
      return;
    }

    await FirebaseFirestore.instance.collection("catererItems").add({
      "userId": userId,
      "foodName": _nameCtrl.text,
      "price": _priceCtrl.text,
      "description": _descCtrl.text,
      "imageUrl": "", // Add storage upload if needed
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Item Added")));
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item"), backgroundColor: AppColors.red),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: _image == null
                    ? const Icon(Icons.image, size: 50)
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Dish Name")),
            TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: "Price")),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveItem,
              child: const Text("Save"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            ),
          ],
        ),
      ),
    );
  }
}
