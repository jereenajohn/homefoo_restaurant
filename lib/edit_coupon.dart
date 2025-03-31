import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class UpdateCoupons extends StatefulWidget {
  final int id;
  const UpdateCoupons({super.key, required this.id});

  @override
  State<UpdateCoupons> createState() => _UpdateCouponsState();
}

class _UpdateCouponsState extends State<UpdateCoupons> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController mincartController = TextEditingController();
  final TextEditingController validfromController = TextEditingController();
  final TextEditingController validtoController = TextEditingController();
  List<Map<String, dynamic>> coupons = [];

  String selectedType = 'Active';
  List<String> Types = ['Active', 'Inactive'];

 @override
  void initState() {
    super.initState();
    getcoupon();

    print("wwwwwwwwwww=========${widget.id}");
  }



  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRestaurantIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> updatecoupon() async {
    try {
      final token = await gettokenFromPrefs();

      var response = await http.put(
        Uri.parse(
            'https://store-firewire-anticipated-actual.trycloudflare.com/HOMFOO-restaurant/coupons/update/${widget.id}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'code': codeController.text,
            'discount': discountController.text,
            'min_cart_total': mincartController.text,
            'valid_from': validfromController,
            'valid_to': validtoController,
            'active': selectedType
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => UpdateCoupo()),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> getcoupon() async {
    final token = await gettokenFromPrefs();
    try {
      final response = await http.get(
        Uri.parse(
            'https://store-firewire-anticipated-actual.trycloudflare.com/HOMFOO-restaurant/coupons/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        List<Map<String, dynamic>> couponlist = [];

        for (var productData in productsData) {
          couponlist.add({
            'id': productData['id'],
            'code': productData['code'],
            'discount': productData['discount'].toString(),
            'min_cart_total': productData['min_cart_total'].toString(),
            'valid_from': productData['valid_from'],
            'valid_to': productData['valid_to'],
            'active': productData['active'].toString(),
          });  

          // If the coupon matches the provided ID, populate text fields
          if (widget.id == productData['id']) {
            setState(() {
              codeController.text = productData['code'] ?? '';
              discountController.text = productData['discount'].toString();
              mincartController.text =
                  productData['min_cart_total'].toString();
              validfromController.text = productData['valid_from'] ?? '';
              validtoController.text = productData['valid_to'] ?? '';
              selectedType =
                  productData['active'] == 'true' ? 'Active' : 'Inactive';
            });
          }
        }

        setState(() {
          coupons = couponlist;
        });
      }
    } catch (e) {
      print('Error fetching coupon: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Coupon')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Coupon Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: discountController,
              decoration: InputDecoration(
                labelText: 'Discount Value',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: mincartController,
              decoration: InputDecoration(
                labelText: 'Minimum cart Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: validfromController,
              decoration: InputDecoration(
                labelText: 'Valid From',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: validtoController,
              decoration: InputDecoration(
                labelText: 'Valid To',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: selectedType,
              items: Types.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value.toString();
                });
              },
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
               child: ElevatedButton(
                onPressed: () {
                  print('Coupon Updated');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Curved border
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15), // Padding for better look
                ),
                child: const Text(
                  'Update Coupon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
               ),
            ),
          ],
        ),
      ),
    );
  }
}
