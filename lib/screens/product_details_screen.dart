import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart'; // Enhancement 3 Legaspi
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Enhancement 3 Legaspi: Add to cart state and logic
  bool _isAdding = false;
  final CartService _cartService = CartService();

  Future<void> _addToCart() async {
    setState(() {
      _isAdding = true;
    });
    try {
      // Simulate adding to cart using DummyJSON carts/add endpoint with user 5
      await _cartService.addToCart(5, [
        {'id': widget.product.id, 'quantity': 1}
      ]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product.title} added to cart!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: widget.product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.thumbnail,
              width: double.infinity,
              height: 300.h,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: widget.product.title,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: '\$${widget.product.price.toStringAsFixed(2)}',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Description',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(text: widget.product.description, fontSize: 14.sp),
                  SizedBox(height: 16.h),
                  CustomText(
                    text:
                        'Brand: ${widget.product.brand.isNotEmpty ? widget.product.brand : "Unknown"}',
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: 'Category: ${widget.product.category}',
                    fontSize: 14.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Enhancement 3 Legaspi: Add to cart button at the bottom
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: ElevatedButton(
            onPressed: _isAdding ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isAdding
                ? SizedBox(
                    width: 24.sp,
                    height: 24.sp,
                    child: const CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                  )
                : CustomText(
                    text: 'Add to Cart',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
          ),
        ),
      ),
    );
  }
}
