import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteProductsScreen extends StatefulWidget {
  final Set<String> favoriteList; // Pass the favorite product IDs

  FavoriteProductsScreen({required this.favoriteList});

  @override
  _FavoriteProductsScreenState createState() => _FavoriteProductsScreenState();
}

class _FavoriteProductsScreenState extends State<FavoriteProductsScreen> {
  List<DocumentSnapshot> favoriteProducts = []; // To store favorite products

  @override
  void initState() {
    super.initState();
    _fetchFavoriteProducts(); // Fetch favorite products on screen load
  }

  // Function to fetch favorite products from Firestore
  void _fetchFavoriteProducts() async {
    if (widget.favoriteList.isEmpty) return; // No favorites to fetch

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where(FieldPath.documentId, whereIn: widget.favoriteList.toList())
        .get();

    setState(() {
      favoriteProducts = querySnapshot.docs; // Assign the favorite products
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Favorite Products",
          style: GoogleFonts.beVietnamPro(
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: favoriteProducts.isEmpty
          ? Center(child: Text('No favorite products available.'))
          : ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          var item = favoriteProducts[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shadowColor: Colors.black,
              child: InkWell(
                child: Container(
                  color: Colors.white.withOpacity(.2),
                  height: 120,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: [
                      Card(
                        shadowColor: Colors.black,
                        child: Container(
                          color: Colors.white,
                          height: 100,
                          width: 100,
                          child: Image.network(item['imageUrl']),
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['productName'] ?? 'No description',
                              style: GoogleFonts.beVietnamPro(
                                textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '₹ ${item['price'] ?? 'No price available'}',
                              style: GoogleFonts.beVietnamPro(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['category'] ?? 'No category available',
                                  style: GoogleFonts.beVietnamPro(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(.6),
                                    ),
                                  ),
                                ),
                                Text(
                                  item['date'] ?? 'No category available',
                                  style: GoogleFonts.beVietnamPro(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
