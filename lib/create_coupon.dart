import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homefoo_restaurant/edit_coupon.dart';
import 'package:homefoo_restaurant/update_coupon.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateCoupon extends StatefulWidget {
  const CreateCoupon({super.key});

  @override
  State<CreateCoupon> createState() => _CreateCouponState();
}

class _CreateCouponState extends State<CreateCoupon> {
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

  void addcoupon() async {
    final token = await gettokenFromPrefs();
    final restaurantId = await getRestaurantIdFromPrefs();

    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Restaurant ID not found.'),
        ),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(
            'https://store-firewire-anticipated-actual.trycloudflare.com/HOMFOO-restaurant/couponcreate/'),
        headers: {
          'Authorization': '$token',
        },
        body: {
          "code": _codeController.text,
          "discount": _discountController.text,
          "min_cart_total": _mincarttotalController.text,
          "restaurant": restaurantId,
          "valid_from": _validfromController.text,
          "valid_to": _validtoController.text,
          "active": _selectedStatus,
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Coupon Created Successfully!'),
          ),
        );
        getcoupon(); // Refresh the list after adding a coupon
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred. Please try again.'),
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
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        setState(() {
          coupons = productsData.map<Map<String, dynamic>>((productData) {
            return {
              'id': productData['id'],
              'code': productData['code'],
              'discount': productData['discount'],
              'min_cart_total': productData['min_cart_total'],
              'valid_from': productData['valid_from'],
              'valid_to': productData['valid_to'],
              'active': productData['active'],
            };
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to fetch coupons.'),
        ),
      );
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
              _buildTextField(_discountController, 'Discount (%)', Icons.percent),
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
                  onPressed: addcoupon,
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
              SizedBox(
                height: 300, // Ensuring a limited height for scrolling
                child: ListView.builder(
                  itemCount: coupons.length,
                  itemBuilder: (context, index) {
                    return _buildCouponCard(coupons[index]);
                  },
                ),
              ),
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

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
  String formatDate(String dateTimeString) {
    return dateTimeString.split('T')[0]; // Extracts only the date part
  }

  return Stack(
    children: [
      Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Code: ${coupon['code']}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                "Discount: ${coupon['discount']}%\n"
                "Min Cart: ₹${coupon['min_cart_total']}\n"
                "Valid: ${formatDate(coupon['valid_from'])} - ${formatDate(coupon['valid_to'])}",
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    coupon['active'] == 'Active' ? Icons.check_circle : Icons.cancel,
                    color: coupon['active'] == 'Active' ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      Positioned(
        bottom: 15, // Adjust position at the bottom
        right: 8,  // Adjust position at the right
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.blue,
          onPressed: () {

            Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateCoupons(id:coupon['id'])));
            // Implement the edit functionality
            print("Edit coupon: ${coupon['id']}");
          },
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    ],
  );
}
}