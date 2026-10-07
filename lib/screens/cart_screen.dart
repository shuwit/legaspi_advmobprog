import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
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
  Cart? _cart;
  bool _isLoading = true;
  String? _error;
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    // Enhancement 3 Legaspi: fetch cart by user id 5
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cart = await _cartService.getCartByUserId(5);
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeQuantity(int productId, int delta) {
    final cart = _cart;
    if (cart == null) return;

    final products = cart.products.map((item) {
      if (item.id != productId) return item;
      final nextQuantity = item.quantity + delta;
      if (nextQuantity < 1) return item;
      return item.copyWith(quantity: nextQuantity);
    }).toList();

    setState(() {
      _cart = cart.copyWith(products: products);
    });
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.only(right: 20.w),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 28.sp,
      ),
    );
  }

  void _removeItem(int productId) {
    final cart = _cart;
    if (cart == null) return;

    setState(() {
      _cart = cart.copyWith(
        products: cart.products.where((item) => item.id != productId).toList(),
      );
    });
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: CustomText(
          text: 'Error: $_error',
          fontSize: 14.sp,
        ),
      );
    }

    final cart = _cart;
    if (cart == null || cart.products.isEmpty) {
      return Center(
        child: CustomText(
          text: 'Your cart is empty.',
          fontSize: 14.sp,
        ),
      );
    }

    final deliveryFee = 0.00; // Mock delivery fee

    return SafeArea(
      child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) {
                    final item = cart.products[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: _deleteBackground(),
                      secondaryBackground: _deleteBackground(),
                      onDismissed: (_) => _removeItem(item.id),
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
                              Expanded(
                                child: GestureDetector(
                                  // Enhancement 1 Legaspi
                                  onTap: () => _navigateToDetailScreen(item.id),
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
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _changeQuantity(item.id, 1),
                                    child: Container(
                                      width: 32.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.add, size: 20.sp, color: Colors.black87),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                    child: CustomText(
                                      text: '${item.quantity}',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _changeQuantity(item.id, -1),
                                    child: Container(
                                      width: 32.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(Icons.remove, size: 20.sp, color: Colors.black87),
                                    ),
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
      ),
    );
  }
}
