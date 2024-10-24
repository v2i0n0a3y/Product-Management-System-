import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'displaydata.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  Uint8List? _imageBytes;
  String? _imageUrl;
  final picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Pick image from gallery
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = imageBytes;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  // Upload data to Firebase Storage and Firestore
  Future _uploadData() async {
    if (_imageBytes != null) {
      try {
        Reference ref = storage.ref().child('productImages/${DateTime.now().millisecondsSinceEpoch}.jpg');
        UploadTask uploadTask = ref.putData(_imageBytes!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await firestore.collection('products').add({
          'imageUrl': downloadUrl,
          'productName': productNameController.text,
          'price': priceController.text,
          'date': datePickerController.text,
          'category': selectedCategory,
          'description': descriptionController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product Uploaded!')),
        );

        setState(() {
          _imageUrl = downloadUrl;
        });

        productNameController.clear();
        datePickerController.clear();
        priceController.clear();
        descriptionController.clear();
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsList()));

      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(2015),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    setState(() {
      datePickerController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategory;
  final List<String> categories = ['Furniture', 'Stationary', 'Electronics', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text("Add Product!",
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: productNameController, hint: "Product Name", icon: Icons.production_quantity_limits),
                const SizedBox(height: 20),
                _buildTextField(controller: priceController, hint: "Price of Product", icon: Icons.money),
                const SizedBox(height: 20),
                _buildTextField(controller: datePickerController, hint: "Select the date", icon: Icons.date_range,
                    onTap: () => onTapFunction(context: context)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category, color: Colors.black54),
                    hintText: "Category",
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: GoogleFonts.beVietnamPro(
                        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.8),
                      )),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  maxLines: 6,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "Description",
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _imageUrl != null
                        ? Image.network(_imageUrl!, height: 250, width: 250)
                        : _imageBytes != null
                        ? Image.memory(_imageBytes!, height: 250, width: 250)
                        : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No image selected.', style: GoogleFonts.beVietnamPro(
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      onTap: pickImage,
                      child: Container(
                        height: 50, width: 400,
                        decoration: BoxDecoration(color: Colors.black.withOpacity(.2), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 10.0), child: Icon(Icons.photo_camera_back, color: Colors.black54)),
                            const SizedBox(width: 10),
                            Text("Pick the image", style: GoogleFonts.beVietnamPro(
                              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.8),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50, width: 400,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD56C60)),
                    onPressed: _uploadData,
                    child: Text("Submit", style: GoogleFonts.beVietnamPro(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
                    )),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, VoidCallback? onTap}) {
    return SizedBox(
      height: 50, width: 400,
      child: TextField(
        controller: controller,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black,
        ),
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
