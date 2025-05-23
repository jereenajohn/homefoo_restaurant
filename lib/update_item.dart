import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:file_picker/file_picker.dart';
import 'package:homefoo_restaurant/api.dart';
import 'package:homefoo_restaurant/home.dart';



import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class update_product extends StatefulWidget {
   
   var id;
   update_product({Key? key,  required this.id}) : super(key: key);

  @override
  State<update_product> createState() => _update_productState();
}

class _update_productState extends State<update_product> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCategories();
    fetchProducts(widget.id);

  }
  String? token;
// sharedpreference
String? imageUrl1;
String? imageUrl2;
String? imageUrl3;
  Future<String?> getUserIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
    }

    //categoreis dropdown
 List<Map<String, dynamic>> categories = [];
Future<void> fetchProducts(var Id) async 
  {
print('${a.productidview}/${widget.id}');
    final token = await gettokenFromPrefs();
    print("8888888888888888888888888888888888'${a.productidview}${widget.id}/'");
    try {
     var response = await http.get(Uri.parse('${a.productidview}${widget.id}/'));
        print("8888888888888888888888888888888888${response.body}");


      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        name.text = productsData['name'];
  price.text = productsData['price'].toString();
  Offers.text = productsData['offer'].toString();
  description.text = productsData['description'];
  selectedCategoryId = productsData['category'].toString();
       setState(() {
    imageUrl1 = "${a.base}${productsData['image1']}";
    imageUrl2 = "${a.base}${productsData['image2']}";
    imageUrl3 = "${a.base}${productsData['image3']}";
  });
      } else {
        throw Exception('Failed to  products');
      }
    } catch (error) {
      print('Error fetching  products: $error');
    }
  }

  Future<void> fetchCategories() async {
  try {
    final response = await http.get(Uri.parse("https://store-firewire-anticipated-actual.trycloudflare.com/categories/"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> categoriesData = responseData['data'];
      List<Map<String, dynamic>> categoriesList = [];

      for (var categoryData in categoriesData) {
        categoriesList.add({
          'id': categoryData['id'],
          'name': categoryData['name'],
        });
      }

      setState(() {
        categories = categoriesList;
      });
    }
  } catch (error) {
    print('Error fetching categories: $error');
  }
}

String? selectedCategoryId; 

  File? selectedImage;

   void imageSelect() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        selectedImage = File(result.files.single.path!);
        imageUrl1 = null; // Clear the URL if a new image is selected
        print("================$selectedImage");
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Image1 selected successfully."),
        backgroundColor: Color.fromARGB(173, 120, 249, 126),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error while selecting the file."),
      backgroundColor: Colors.red,
    ));
  }
}


   File? selectedImage2;

    void imageSelect2() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        selectedImage2 = File(result.files.single.path!);
        imageUrl2 = null; // Clear the URL if a new image is selected
        print("================$selectedImage2");
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Image2 selected successfully."),
        backgroundColor: Color.fromARGB(173, 120, 249, 126),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error while selecting the file."),
      backgroundColor: Colors.red,
    ));
  }
}
   File? selectedImage3;

    void imageSelect3() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        selectedImage3 = File(result.files.single.path!);
        imageUrl3 = null; // Clear the URL if a new image is selected
        print("================$selectedImage3");
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Image3 selected successfully."),
        backgroundColor: Color.fromARGB(173, 120, 249, 126),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error while selecting the file."),
      backgroundColor: Colors.red,
    ));
  }
}
  TextEditingController name= TextEditingController();
  TextEditingController price= TextEditingController();
  TextEditingController Offers= TextEditingController();
  TextEditingController description= TextEditingController();
 
   
    var selectedfile;
    api a=api();


void updateItem(
  String url,
  String name,
  String price,
  File? image1,
  File? image2,
  File? image3,
  String offers,
  String description,
  String categoryid,
  BuildContext scaffoldContext,
  String token,
) async {
  if ( name.isEmpty || price.isEmpty) {
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text('Please fill out all fields.'),
      ),
    );
    return;
  }
  try {
    var request = http.MultipartRequest('PUT', Uri.parse('$url${widget.id}/')); // Assuming the URL format for updating data is like 'https://example.com/api/resource/id'

      request.headers['Authorization'] = '$token';

    // Add text fields to the request
    request.fields['name'] = name;
    request.fields['price'] = price;
    request.fields['offer'] = offers;
    request.fields['description'] = description;
    request.fields['category'] = categoryid;

    // Add images to the request if they are not null
    if (image1 != null) {
      request.files.add(await http.MultipartFile.fromPath('image1', image1.path));
    }
    if (image2 != null) {
      request.files.add(await http.MultipartFile.fromPath('image2', image2.path));
    }
    if (image3 != null) {
      request.files.add(await http.MultipartFile.fromPath('image3', image3.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // Handle response based on status code
    if (response.statusCode == 200) {
      // Update successful
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        
        SnackBar(
          content: Text('Data Updated Successfully.'),
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
      // Optionally, navigate to another page or update UI as needed
    } else {
      // Handle other status codes
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again later.'),
        ),
      );
    }
  } catch (e) {
    // Handle network errors or exceptions
    print("Error: $e");
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text('Network error. Please check your connection.'),
      ),
    );
  }
}


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Builder(
        builder: (BuildContext scaffoldContext) {
          return SingleChildScrollView(
            child: Container(

              child: Column(
              children: [


                  Container(
                    height: 80,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 183, 183, 183).withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 35,left: 20),
                child: Row(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
                          },
                          child: Image.asset(
                            "lib/assets/backarrow.png",
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                 
                 
                  ],
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.only(top: 40,left: 15,right: 15),
              child: Container(
                

                 decoration: BoxDecoration(

                  color: Colors.white,
    
    borderRadius: BorderRadius.circular(10.0), // Border radius
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5), // Shadow color
        spreadRadius: 3, // How spread out the shadow is
        blurRadius: 5, // How blurry the shadow is
        offset: Offset(0, 3), // Changes the position of the shadow
      ),
    ],
  ),
               
                child: Column(
                  children: [
              
              
                              SizedBox(height: 30,),
                
                 Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Update Item !",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                ],
                    ),
                  
                  SizedBox(height: 15),
                        
                  Container(
                    child: Column(
                      children: [
                        
                             
                  Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Container(
                child: Column(
                  children: [
                     TextField(
                      controller: name,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    filled: true,
                    fillColor: Colors.white,
                   
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                ),
                SizedBox(height: 15,),
                TextField(
                      controller: price,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    filled: true,
                    fillColor: Colors.white,
                   
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                ),
                 SizedBox(height: 15,),

                   GestureDetector(
                  onTap: () {
                    imageSelect();
                  },
                   child: Container(
                    
                     height: 55,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Color.fromARGB(255, 224, 223, 223),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Image.asset(
                           'lib/assets/upload.png', // Replace 'upload_icon.png' with your image asset path
                           width: 24, // Adjust the width of the image
                           height: 24, // Adjust the height of the image
                           color: Color.fromARGB(255, 2, 2, 2), // Adjust the color of the image
                         ),
                         SizedBox(width: 10), // Spacer between icon and text
                         Text(
                           "Select Image",
                           style: TextStyle(color: const Color.fromARGB(255, 116, 116, 116)),
                         ),
                       ],
                     ),
                     
                   ),
                 ),

                selectedImage != null ? Image.file(selectedImage!) : (imageUrl1 != null ? Image.network(imageUrl1!) : Container()),

                  SizedBox(height: 15,),

                 

                  GestureDetector(
                  onTap: () {
                    imageSelect2();
                  },
                   child: Container(
                    
                     height: 55,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Color.fromARGB(255, 224, 223, 223),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Image.asset(
                           'lib/assets/upload.png', // Replace 'upload_icon.png' with your image asset path
                           width: 24, // Adjust the width of the image
                           height: 24, // Adjust the height of the image
                           color: Color.fromARGB(255, 2, 2, 2), // Adjust the color of the image
                         ),
                         SizedBox(width: 10), // Spacer between icon and text
                         Text(
                           "Select Image",
                           style: TextStyle(color: const Color.fromARGB(255, 116, 116, 116)),
                         ),
                       ],
                     ),
                     
                   ),
                 ),
                 selectedImage2 != null ? Image.file(selectedImage2!) : (imageUrl2 != null ? Image.network(imageUrl2!) : Container()),
                  SizedBox(height: 15,),
                 
                  GestureDetector(
                  onTap: () {
                    imageSelect3();
                  },
                   child: Container(
                    
                     height: 55,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Color.fromARGB(255, 224, 223, 223),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Image.asset(
                           'lib/assets/upload.png', // Replace 'upload_icon.png' with your image asset path
                           width: 24, // Adjust the width of the image
                           height: 24, // Adjust the height of the image
                           color: Color.fromARGB(255, 2, 2, 2), // Adjust the color of the image
                         ),
                         SizedBox(width: 10), // Spacer between icon and text
                         Text(
                           "Select Image",
                           style: TextStyle(color: const Color.fromARGB(255, 116, 116, 116)),
                         ),
                       ],
                     ),
                     
                   ),
                 ),

                 selectedImage3 != null ? Image.file(selectedImage3!) : (imageUrl3 != null ? Image.network(imageUrl3!) : Container()),

               
               
                SizedBox(height: 15,),
                TextField(
                   controller: Offers,
                  decoration: InputDecoration(
                    labelText: 'Offers',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    filled: true,
                    fillColor: Colors.white,
                   
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                ),
                SizedBox(height: 15,),
                TextField(
                   controller: description,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 165, 165, 165)), // Change border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 170, 170, 170).withOpacity(0.5)), // Change enabled border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 188, 2, 2)), // Change focused border color here
                      borderRadius: BorderRadius.circular(10.0), // Optional: change border radius
                    ),
                    filled: true,
                    fillColor: Colors.white,
                
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                ),
 SizedBox(height: 15,),
Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            border: InputBorder.none,
          ),
          value: selectedCategoryId,
          hint: Text('Select a category'),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategoryId = newValue;
            });
          },
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id'].toString(),
              child: Text(category['name']),
            );
          }).toList(),
        ),
      ),


                  ],
                ),
              ),
                  ),
                 
                        
                      ],
                    ),
                  ),
                 
               
                    
                        
                
                 
                  SizedBox(height: 20,),
                  // Sign In Button
                  Container(
              width: MediaQuery.of(context).size.width * 0.6, // Set button width as half of the screen width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0), // Border radius for button
                color: const Color.fromARGB(255, 243, 33, 33),
              ),
              child: TextButton(
                onPressed: () async {
                 token = await gettokenFromPrefs();
               
                  updateItem(a.uproduct,name.text,price.text,selectedImage,selectedImage2,selectedImage3,Offers.text,description.text,selectedCategoryId!,scaffoldContext,token!);
                 
                },
                child: Text(
                  "UPDATE",
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 16.0,
                  ),
                ),
              ),
                  ),
                  
                       SizedBox(height: 40,),  
                    
                  ],
                ),
              ),
            )


      
          
          
              ],
            )
            
            ),
          );
        }
      )

    
  );




  }
}