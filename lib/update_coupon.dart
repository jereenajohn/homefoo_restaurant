import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateCoupon extends StatefulWidget {
  final int id;

  const UpdateCoupon({super.key, required this.id});

  @override
  State<UpdateCoupon> createState() => _UpdateCouponState();
}

class _UpdateCouponState extends State<UpdateCoupon> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _mincarttotalController = TextEditingController();
  final TextEditingController _validfromController = TextEditingController();
  final TextEditingController _validtoController = TextEditingController();
  List<Map<String, dynamic>> coupons = [];

  String _selectedStatus = 'Active'; // Default selected value

  @override
  void initState() {
    super.initState();
    getcoupon();

    print("wwwwwwwwwww=======================${widget.id}");
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRestaurantIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = pickedDate.toString().split(' ')[0];
      });
    }
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
            'code': _codeController.text,
            'discount': _discountController.text,
            'min_cart_total': _mincarttotalController.text,
            'valid_from': _validfromController,
            'valid_to': _validtoController,
            'active': _selectedStatus
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
              _codeController.text = productData['code'] ?? '';
              _discountController.text = productData['discount'].toString();
              _mincarttotalController.text =
                  productData['min_cart_total'].toString();
              _validfromController.text = productData['valid_from'] ?? '';
              _validtoController.text = productData['valid_to'] ?? '';
              _selectedStatus =
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
      appBar: AppBar(
        title: const Text('Create Coupon'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  _codeController, 'Coupon Code', Icons.card_giftcard),
              const SizedBox(height: 12),
              _buildTextField(
                  _discountController, 'Discount (%)', Icons.percent),
              const SizedBox(height: 12),
              _buildTextField(_mincarttotalController, 'Minimum Cart Total',
                  Icons.shopping_cart),
              const SizedBox(height: 12),
              _buildDateField(
                  _validfromController, 'Valid From', Icons.calendar_today),
              const SizedBox(height: 12),
              _buildDateField(
                  _validtoController, 'Valid To', Icons.calendar_today),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['Active', 'Inactive'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.toggle_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Status',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updatecoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Coupon',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Scrollable ListView inside a Fixed Height SizedBox
              // SizedBox(
              //   height: 300, // Ensuring a limited height for scrolling
              //   child: ListView.builder(
              //     itemCount: coupons.length,
              //     itemBuilder: (context, index) {
              //       return _buildCouponCard(coupons[index]);
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onTap: () => _selectDate(context, controller),
    );
  }
}
