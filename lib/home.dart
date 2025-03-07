import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homefoo_restaurant/additems.dart';
import 'package:homefoo_restaurant/api.dart';
import 'package:homefoo_restaurant/login.dart';
import 'package:homefoo_restaurant/update_item.dart';


import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:google_nav_bar/google_nav_bar.dart';

class home extends StatefulWidget {
  final String? userId; 
  home({Key? key, this.userId}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  List<Map<String, dynamic>> filteredProducts = [];
TextEditingController searchController = TextEditingController();
   String? userId; 
  void initState() {
  super.initState();
  _initData();
}

//delete

Future<void> deleteProduct(int pId) async {
  token = await gettokenFromPrefs();
   print("uuuuuuuuuuuuuuuuuuuuuuuuuu");
    try {
      final response = await http.delete(
        Uri.parse('${a.dproduct}$pId/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
           'Authorization': '$token',
        },
      );
      print("uuuuuuuuuuuuuuuuuuuuuuuuuu ${a.dproduct}$pId/");
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 204) {
        print('Wishlist ID deleted successfully: $pId');
      } else {
        throw Exception('Failed to delete wishlist ID: $pId');
      }
    } catch (error) {
      print('Error: $error');
}
}


 String? token;
 
// sharedpreference

  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
    }

Future<void> _initData() async {
  userId = await getUserIdFromPrefs();
  // print("--------------------------------------------R$userId");
  _getCurrentPosition();
  _startTimer();
  fetchCategories();
  fetchProducts(userId); // Use userId after getting the value
}


  // Function to handle logout
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Clear user ID from shared preferences
    Navigator.pop(context); // Navigate back to the previous screen (login or wherever you came from)
  }

  Future<void> refresh() async {
    String? updatedUserId = await getUserIdFromPrefs();
    setState(() {
      userId = updatedUserId;
    });
  }

  //product view



  List<Map<String, dynamic>> Products = [];
  late List<bool> isFavorite;


  void searchProducts(String query) {
    setState(() {
      filteredProducts = Products
          .where((product) =>
              product['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
//product
  Future<void> fetchProducts(String? userId) async 
  {

    final token = await gettokenFromPrefs();
    print("8888888888888888888888888888888888${token}");
    try {
     var response = await http.post(Uri.parse(a.productview), headers: {
      'Authorization': '$token',
    }, body: {
      'token': token,
    });
        print("8888888888888888888888888888888888${response.body}");


      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> productsData = parsed['data'];
        List<Map<String, dynamic>> productsList = [];
        List<bool> favoritesList = [];

        for (var productData in productsData) {
          // Fetch image URL
          String imageUrl =
              "https://describes-soldier-hourly-cartoon.trycloudflare.com/${productData['image1']}";
          // You might need to adjust the URL based on your API response structure

          productsList.add({
            'id': productData['id'],
            'category_id': productData['category'],
            'name': productData['name'],
            'price': productData['price'],
            'image': imageUrl,
            'offer': productData['offer'],
            'description': productData['description'],
          });

          favoritesList.add(false);
        }

        setState(() {
          Products = productsList;
          filteredProducts = productsList;
          isFavorite = favoritesList;
        });
      } else {
        throw Exception('Failed to  products');
      }
    } catch (error) {
      print('Error fetching  products: $error');
    }
  }

  // remove product

  void removeProduct(int index) {
    setState(() {
      Products.removeAt(index);
});}

//search

  int _index = 0;

  bool _isSearching = false;

  void _showSearchDialog(BuildContext context) {
    setState(() {
      _isSearching = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                          });
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ),
                  ),
                ),
                // Add search results here
              ],
            ),
          ),
        );
      },
    );
  }

  api a = api();
  bool isSwitched = false;
  PageController _pageController = PageController();
  var url = "https://describes-soldier-hourly-cartoon.trycloudflare.com/categories/";
  late Timer _timer;
  List<String> bannerImageBase64Strings = [];
  String? _currentAddress;
  Position? _currentPosition;
  List<Map<String, dynamic>> categories = [];
  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  void _startTimer() {
    const Duration duration =
        Duration(seconds: 5); // Adjust the duration as needed
    _timer = Timer.periodic(duration, (Timer timer) {
      if (_pageController.hasClients) {
        if (_pageController.page == bannerImageBase64Strings.length - 1) {
          _pageController.animateToPage(0,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        } else {
          _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        }
      }
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            ' ${place.subLocality} ${place.subAdministrativeArea}';
      });

      // print('====================================$_currentAddress');
    }).catchError((e) {
      debugPrint(e);
    });
  }

  //local storage

  Future<void> storeDataLocally(String key, String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  Future<String?> getDataLocally(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

//banner

  Future<String> convertImageToBase64(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    } else {
      throw Exception('Failed to load image: $imageUrl');
    }
  }

  //category

Future<void> fetchCategories() async {
  try {
    final String key = 'categories_data';
    String? localData = await getDataLocally(key);

    if (localData != null) {
      setState(() {
        // Use local data
        categories = jsonDecode(localData).cast<Map<String, dynamic>>();
      });
    } else {
      final response = await http.get(Uri.parse(url));
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Access the 'data' key which contains the list of categories
        final List<dynamic> categoriesData = responseData['data'];
        List<Map<String, dynamic>> categoriesList = [];

        for (var categoryData in categoriesData) {
          String imageUrl = "${a.base}${categoryData['image']}";
          String base64Image = await convertImageToBase64(imageUrl);
          categoriesList.add({
            'id': categoryData['id'],
            'name': categoryData['name'],
            'imageBase64': base64Image,
          });
        }

        setState(() {
          categories = categoriesList;
        });

        // Store data locally
        await storeDataLocally(key, jsonEncode(categoriesList));
      } else {
        throw Exception('Failed to load categories');
      }
    }
  } catch (error) {
    print('Error fetching categories: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double carouselWidth = screenWidth * 0.9;
    return Scaffold(
      backgroundColor: Colors.white,
    
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 183, 183, 183)
                          .withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            "lib/assets/logo.png",
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      if(_currentAddress!=null)
                      Text(' $_currentAddress',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset(
                              "lib/assets/notification.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 17),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 227, 252, 208),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 5),
                          Text(
                            "Available Status:",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            isSwitched ? 'OPEN' : 'CLOSED',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 91, 187, 94),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Switch(
                            value: isSwitched,
                            onChanged: (value) {
                              setState(() {
                                isSwitched = value;
                              });
                            },
                            activeTrackColor:
                                Color.fromARGB(255, 197, 250, 157),
                            activeColor: Color.fromARGB(255, 91, 187, 94),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              categories.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 115,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 232, 232, 232),
                                      image: DecorationImage(
                                        image: MemoryImage(base64Decode(
                                            categories[index]['imageBase64'])),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    categories[index]['name'],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                Padding(
  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
  child: TextField(
    controller: searchController,
    onChanged: searchProducts,
    decoration: InputDecoration(
      hintText: "Search for a product...",
      prefixIcon: Icon(Icons.search, color: Colors.green),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey), // Default border color
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.green, width: 2), // Green border when focused
      ),
    ),
  ),
),

              filteredProducts != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        var product = filteredProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=>productbigview(Products[index]['id'])));
                            },
                            child: Container(
                                height: 160,
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                product['image'],
                                                width: 110,
                                                height: 110,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start, // Align children to start horizontally
                                            children: [
                                              SizedBox(height: 16.0),
                                              Text(product["name"]),
                                              SizedBox(height: 10.0),
                                              Text(
                                                '\$ ${product['price']}',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                              Row(
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>update_product(id:product['id'])));
                                                    },
                                                    child: Text(
                                                      "Edit",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    style: ButtonStyle(
                                                      // Set button height and width
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Size(20, 25)),
                                                      // Set button border radius
                                                      shape: MaterialStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          // Optionally, you can set border color and width
                                                        ),
                                                      ),
                                                      // Set button background color
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.green),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async{
                                                       
                                                      deleteProduct(product["id"]);
                                                      removeProduct(index);



                                                    },
                                                    child: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    style: ButtonStyle(
                                                      // Set button height and width
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Size(20, 25)),
                                                      // Set button border radius
                                                      shape: MaterialStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          // Optionally, you can set border color and width
                                                        ),
                                                      ),
                                                      // Set button background color
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Color
                                                                  .fromARGB(
                                                                      255,
                                                                      237,
                                                                      8,
                                                                      8)),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Expanded(
                                    //       child: Container(
            
                                    //         height: 1,
                                    //         color: const Color.fromARGB(255, 211, 210, 210),
                                    //       ),
                                    //     )
            
                                    //   ],
                                    // ),
                                    // Row(
                                    //   children: [
                                    //     Text("")
            
                                    //   ],
                                    // )
                                  ],
                                )),
                          ),
                        );
                      },
                    )
                  : Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    
      // ListTile(
      //             leading: ClipRRect(
      //               borderRadius: BorderRadius.circular(8.0),
      //               child: Image.network(
      //                 product['image'],
      //                 width: 100,
      //                 height: 100,
      //                 fit: BoxFit.cover,
      //               ),
      //             ),
      //             title: Text(product['name']),
      //             subtitle: Text('\$${product['price']}'),
      //           ),
    
      //bottom navigation
    
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 244, 244, 244),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: GNav(
            gap: 20,
            onTabChange: (index) {
              setState(() {
                _index = index;
                if (index == 2) {
                  _showSearchDialog(context);
                }
              });
            },
            padding: EdgeInsets.all(16),
            selectedIndex: _index,
            tabs: [
              GButton(
                icon: Icons.home,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              home(userId: widget.userId)));
                  // Navigate to Home page
                },
              ),
              GButton(
                icon: Icons.shopping_bag,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              add_product()));
                  // Navigate to Cart page
                },
              ),
              GButton(
                icon: Icons.search,
                onPressed: () {
                  // Show search dialog if tapped
                },
              ),
              GButton(
                icon: Icons.person,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => login()));
                  // Navigate to Profile page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await fetchCategories();
    await fetchProducts(userId);
    await _getCurrentPosition();
    _startTimer();
  }
}
