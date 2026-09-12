import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/user_service.dart'; // Enhancement 3 Legaspi
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

// Enhancement 1 Legaspi
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Enhancement 3 Legaspi
  late Future<Cart> _cartFuture;
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService(); // Enhancement 3 Legaspi

  @override
  void initState() {
    super.initState();
    // Enhancement 3 Legaspi: fetch cart using saved user id
    _cartFuture = _loadCartBySavedUser();
  }

  // Enhancement 3 Legaspi
  Future<Cart> _loadCartBySavedUser() async {
    final userData = await _userService.getUserData();
    final userId = userData['id'] as int? ?? 0;
    if (userId <= 0) {
      throw Exception('No saved user id found. Please sign in again.');
    }
    return _cartService.getCartByUserId(userId);
  }

  void _navigateToDetailScreen(int productId) async {
    try {
      final product = await _productService.getProductById(productId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: CustomText(
                text: 'Error: ${snapshot.error}',
                fontSize: 14.sp,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
            return Center(
              child: CustomText(
                text: 'Your cart is empty.',
                fontSize: 14.sp,
              ),
            );
          }

          final cart = snapshot.data!;
          final deliveryFee = 0.00; // Mock delivery fee

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) {
                    final item = cart.products[index];
                    return GestureDetector(
                      // Enhancement 1 Legaspi
                      onTap: () => _navigateToDetailScreen(item.id),
                      child: Card(
                        elevation: 1,
                        margin: EdgeInsets.only(bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            children: [
                              Image.network(
                                item.thumbnail,
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.image, size: 40.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: item.title,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    CustomText(
                                      text: '\$${item.price.toStringAsFixed(2)}',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orangeAccent,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      text: '${item.discountPercentage}% off • \$${item.discountedTotal.toStringAsFixed(2)} total',
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 32.w,
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(Icons.add, size: 20.sp, color: Colors.black87),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                    child: CustomText(
                                      text: '${item.quantity}',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    width: 32.w,
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(Icons.remove, size: 20.sp, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(text: 'Subtotal:', fontSize: 14.sp, color: Colors.grey),
                        CustomText(text: '\$${cart.discountedTotal.toStringAsFixed(2)}', fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.amber),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(text: 'Delivery Fee:', fontSize: 14.sp, color: Colors.grey),
                        CustomText(text: '\$${deliveryFee.toStringAsFixed(2)}', fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.amber),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {},
                        child: CustomText(
                          text: 'Confirm Order',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
