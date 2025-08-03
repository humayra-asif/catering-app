import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capp/utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  bool _saving = false;
  int _descWordCount = 0;
  static const int _maxWords = 100;

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    final words = _descCtrl.text.trim().isEmpty
        ? 0
        : _descCtrl.text.trim().split(RegExp(r'\s+')).length;
    setState(() => _descWordCount = words);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<String> _uploadImage(String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child("catererItems")
        .child(userId)
        .child("item_$timestamp.jpg");
    await ref.putFile(_image!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    final name = _nameCtrl.text.trim();
    final price = _priceCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (name.isEmpty || price.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (_descWordCount > _maxWords) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Description exceeds word limit")),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final imageUrl = await _uploadImage(user.uid);

      await FirebaseFirestore.instance.collection("catererItems").add({
        "userId": user.uid,
        "foodName": name,
        "price": price,
        "description": desc,
        "imageUrl": imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item Added Successfully")),
      );

      // Clear form for further adds
      _nameCtrl.clear();
      _priceCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _image = null;
        _descWordCount = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving item: $e")),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(border: InputBorder.none, hintText: hint),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addButton = SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saving ? null : _saveItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _saving
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            : const Text("Add",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Add Item"),
        backgroundColor: AppColors.red,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors2.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _image!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add_circle_outline,
                                  size: 50, color: Colors.black),
                              SizedBox(height: 6),
                              Text("Upload Image",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: _nameCtrl, label: "Dish Name:", hint: "abc"),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _priceCtrl,
                  label: "Price:",
                  hint: "500",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Description :",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _descCtrl,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "abc"),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "$_descWordCount / $_maxWords words",
                        style: TextStyle(
                          fontSize: 12,
                          color: _descWordCount > _maxWords
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                addButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
