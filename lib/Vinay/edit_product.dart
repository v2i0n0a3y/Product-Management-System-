
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddProductScreen extends StatefulWidget {
  final String? productId; // Optional productId for editing
  final DocumentSnapshot? initialData; // Existing product data for editing

  const AddProductScreen({Key? key, this.productId, this.initialData}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _productName;
  String? _price;
  String? _category;
  String? _description;
  String? _date;


  String? selectedCategory;
  final List<String> categories = ['Furniture', 'Stationary', 'Electronics', 'Others'];


  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      // Pre-fill the form with the existing product data
      _productName = widget.initialData!['productName'];
      _price = widget.initialData!['price'].toString();
      _category = widget.initialData!['category'];
      _description = widget.initialData!['description'];
      _date = widget.initialData!['date'];

    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prepare data
      Map<String, dynamic> productData = {
        'productName': _productName,
        'price': double.parse(_price!), // Convert to double
        'category': _category,
        'description': _description,
        'date': _date,

      };

      // If editing (productId is provided), update the existing product
      if (widget.productId != null) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(productData);
      } else {
        // Else, add a new product
        await FirebaseFirestore.instance.collection('products').add(productData);
      }

      Navigator.pop(context); // Go back after saving
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
      _date = DateFormat('dd/MM/yyyy').format(pickedDate); // Update _date directly
      datePickerController.text = _date!; // Reflect in TextEditingController
    });
  }


  final TextEditingController datePickerController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    selectedCategory = _category;
    datePickerController.text = _date.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              _buildIconTextField(
                hint: "Product Name",
                icon: Icons.pending_actions,
                initialValue: _productName.toString(),
                onSaved: (value) => _productName = value!,
              ),
              const SizedBox(height: 20),
              _buildIconTextField(
                hint: "Price",
                icon: Icons.money,
                initialValue: _price.toString(),
                onSaved: (value) => _price = value!,
              ),
              const SizedBox(height: 20),
              _buildIconTextField(
                hint: "Select the date",
                icon: Icons.calendar_month_outlined,
                initialValue: _date ?? '', // Show empty if _date is null
                onSaved: (value) => _date = value!,
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode()); // To prevent keyboard from popping up
                  await onTapFunction(context: context);
                  setState(() {
                    _date = datePickerController.text; // Set the selected date in _date
                  });
                },
              ),


              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                onSaved: (value) => _category = value,
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

              TextFormField(
                initialValue: _description.toString(),
                onSaved: (value) => _description = value!,
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

              SizedBox(height: 20,),

              SizedBox(
                height: 50, width: 400,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: _saveProduct,
                  child: Text(widget.productId != null ? 'Update Product' : 'Add Product', style: GoogleFonts.beVietnamPro(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconTextField({
    required String hint,
    final void Function(String?)? onSaved,
    required String initialValue,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 50,
      width: 400,
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

}
