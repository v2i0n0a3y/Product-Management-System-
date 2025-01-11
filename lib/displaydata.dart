import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:products/addproduct.dart';
import 'Vinay/detailed_screen.dart';
import 'Vinay/favourite.dart';
import 'Vinay/profile.dart';
import 'category/categoryData.dart';


class ProductsList extends StatefulWidget {
  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {

  User? user;
  List<DocumentSnapshot> productList = []; // Full list of products from Firebase
  List<DocumentSnapshot> filteredProductList = []; // For filtered search results
  Set<String> favoriteList = {}; // Stores favorite product IDs
  TextEditingController searchController = TextEditingController(); // Search controller

  @override
  void initState() {
    super.initState();
    getUserData();
    _fetchProducts(); // Fetch products initially
  }

  void getUserData() {
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }


  // Function to fetch products from Firestore
  Future <void> _fetchProducts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      productList = querySnapshot.docs;
      filteredProductList = productList;
    });
  }

  void filterProducts(String query) {
    List<DocumentSnapshot> results = [];
    if (query.isEmpty) {
      results = productList;
    } else {
      results = productList.where((item) {
        return item['productName'] != null &&
            item['productName'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      filteredProductList = results;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? 'No username available',
                style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              accountEmail: Text(
                user?.email ?? 'No email available',
                style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w500, color: Colors.white),
              ),
              currentAccountPicture: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                    user?.displayName != null
                        ? user!.displayName![0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        fontSize: 40.0, color:  Color(0xFF7260FD)),
                  )
                      : null,
                ),
              ),

            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: Text('Favourite', style: GoogleFonts.beVietnamPro(
                textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(.5)),
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteProductsScreen(favoriteList: favoriteList),
                  ),
                );
              },
            ),
            Divider(color: Colors.black.withOpacity(.2),),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Profile', style: GoogleFonts.beVietnamPro(
                textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(.5)),
              ),),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
              },
            ),
            Divider(color: Colors.black.withOpacity(.2),),

          ],
        ),
      ),
      appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25)),
          ),
        backgroundColor: Color(0xFF5956D6),
        title: Text(
          "Products",
          style: GoogleFonts.beVietnamPro(
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite,color: Colors.red,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteProductsScreen(favoriteList: favoriteList),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: GoogleFonts.beVietnamPro(color: Colors.black.withOpacity(.6), fontWeight: FontWeight.w600),
              controller: searchController,
              onChanged: (value) => filterProducts(value), // Call filter function on text input
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: filteredProductList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchProducts,
            child: ListView.builder(
                    itemCount: filteredProductList.length,
                    itemBuilder: (context, index) {
            var item = filteredProductList[index];
              return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shadowColor: Colors.black,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: item.id, // Assuming `item.id` holds the product's document ID from Firestore
                          favoriteList: favoriteList,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.white.withOpacity(.2),
                    height: 120,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['productName'] ?? 'No description',
                                style: GoogleFonts.beVietnamPro(
                                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '₹ ${item['price'] ?? 'No price available'}',
                                style: GoogleFonts.beVietnamPro(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                        IconButton(
                          icon: Icon(
                            favoriteList.contains(item.id) ? Icons.favorite : Icons.favorite_border,
                            color: favoriteList.contains(item.id) ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              if (favoriteList.contains(item.id)) {
                                favoriteList.remove(item.id);
                              } else {
                                favoriteList.add(item.id);
                              }
                            }
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
                    },
                  ),
          ),
    );
  }
}
