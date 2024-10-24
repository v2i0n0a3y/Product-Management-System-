import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../addproduct.dart';
import 'edit_product.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId; // Use the product ID to fetch data from Firestore
  final Set<String> favoriteList;

  const ProductDetailScreen({Key? key, required this.productId, required this.favoriteList}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLiked = false;
  DocumentSnapshot? product; // Store the fetched product data
  bool isLoading = true; // To indicate loading state

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  // Fetch product details from Firebase Firestore
  Future<void> fetchProductDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      setState(() {
        product = doc;
        isLiked = widget.favoriteList.contains(widget.productId);
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error fetching product details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleFavorite() {
    setState(() {
      if (isLiked) {
        widget.favoriteList.remove(widget.productId);
      } else {
        widget.favoriteList.add(widget.productId);
      }
      isLiked = !isLiked;
    });
  }

  // Delete product from Firestore
  Future<void> deleteProduct() async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).delete();
      Navigator.pop(context); // Go back after deletion
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product. Please try again.')),
      );
    }
  }

  // Show confirmation dialog before deletion
  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this product?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteProduct(); // Call the delete function
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product != null ? (product!['productName'] ?? 'Product Detail') : 'Loading...',
          style: GoogleFonts.beVietnamPro(
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to the AddProductScreen for editing
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(
                    productId: widget.productId,
                    initialData: product, // Pass the existing product data for editing
                  ),
                ),
              ).then((_) => fetchProductDetails()); // Refresh product details after edit
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDelete, // Confirm before deleting
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  product?['imageUrl'] ?? '', // Fetch image URL from Firestore
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                product?['productName'] ?? 'No title',
                style: GoogleFonts.beVietnamPro(
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'price: ₹ ${product?['price']?.toString() ?? 'No price available'}', // Display price with ₹ symbol
                style: GoogleFonts.beVietnamPro(
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'category: ${product?['category']?.toString() ?? 'Unknown category'}',
                style: GoogleFonts.beVietnamPro(
                  textStyle: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'description:',
                style: GoogleFonts.beVietnamPro(
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                product?['description'] ?? 'No description available',
                style: GoogleFonts.beVietnamPro(
                  textStyle: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
