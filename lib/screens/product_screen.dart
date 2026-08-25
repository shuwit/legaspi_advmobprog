import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart'; // Enhancement 2 import

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  // Enhancement 1: Add search bar state Legaspi
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts().then((products) {
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
      });
      return products;
    });
  }

  // Enhancement 1 logic Legaspi
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhancement 1: Add search bar above the article list. Legaspi
            TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: CustomText(
                        text: 'Error: \${snapshot.error}',
                        fontSize: 14.sp,
                      ),
                    );
                  }

                  if (_filteredProducts.isEmpty) {
                    return Center(
                      child: CustomText(
                        text: 'No products found.',
                        fontSize: 14.sp,
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return GestureDetector(
                        // Enhancement 2: Add details page when clicked the card. (Added gesture detector for navigation) Legaspi
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  product.thumbnail,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      Icon(Icons.image, size: 24.sp),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: product.title,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    CustomText(
                                      text:
                                          '\$\${product.price.toStringAsFixed(2)}',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
