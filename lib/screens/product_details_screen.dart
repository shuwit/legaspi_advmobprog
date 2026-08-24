import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../widgets/custom_text.dart';

// Enhancement 2: Add details page when clicked the card. (Created details page UI) Legaspi
class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.thumbnail,
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
                    text: product.title,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: '\$\${product.price.toStringAsFixed(2)}',
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
                  CustomText(text: product.description, fontSize: 14.sp),
                  SizedBox(height: 16.h),
                  CustomText(
                    text:
                        'Brand: \${product.brand.isNotEmpty ? product.brand : "Unknown"}',
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: 'Category: \${product.category}',
                    fontSize: 14.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
