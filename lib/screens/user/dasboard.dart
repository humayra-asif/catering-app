import 'dart:async';
import 'package:capp/screens/user/productdetail.dart';
import 'package:capp/screens/user/profile.dart';
import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key, required this.userId});
  final String userId;

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<String> bannerImages = [];
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchBannerImages();
    fetchCatererItems();
    startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (bannerImages.isEmpty) return;
      _currentPage = (_currentPage + 1) % bannerImages.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> fetchBannerImages() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('banners').get();
    final list = <String>[];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['imageUrl'] is List) {
        for (var url in data['imageUrl']) {
          if (url is String && url.isNotEmpty) list.add(url);
        }
      }
    }
    setState(() => bannerImages = list);
  }

  Future<void> fetchCatererItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('catererItems')
        .limit(8)
        .get();
    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id;
      return data;
    }).toList();
    setState(() {
      allItems = list;
      filteredItems = list;
    });
  }

  void searchFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      filteredItems = q.isEmpty
          ? allItems
          : allItems.where((item) {
              final name =
                  (item['foodName'] ?? '').toString().toLowerCase();
              return name.contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.red,
        elevation: 0,
        title: Image.asset('assets/images/CuberLogo.png', height: 40),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // ✅ Wrap with scroll view
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: AppColors2.grey,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Row(
                          children: [
                            const Icon(Icons.manage_search_outlined,
                                color: Colors.black54),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextField(
                                onChanged: searchFilter,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  hintText: "Search...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors2.grey,
                        child: const Icon(Icons.person,
                            color: Colors.black, size: 30),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                /// Banner
                bannerImages.isEmpty
                    ? SizedBox(
                        height: 200.h,
                        child:
                            const Center(child: Text("No banners found")))
                    : Column(children: [
                        SizedBox(
                          height: 200.h,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: bannerImages.length,
                            onPageChanged: (i) =>
                                setState(() => _currentPage = i),
                            itemBuilder: (_, i) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.network(
                                  bannerImages[i],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.red,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: bannerImages.length,
                          effect: ExpandingDotsEffect(
                            dotWidth: 10,
                            dotHeight: 10,
                            activeDotColor: AppColors.red,
                          ),
                        ),
                      ]),

                SizedBox(height: 30.h),

                /// Title row
                Row(
                  children: [
                    Text("Popular Items",
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Divider(),
                    // ❌ Removed invalid Divider from Row
                  ],
                ),
                SizedBox(height: 16.h),

                /// Items grid
                filteredItems.isEmpty
                    ? const Center(child: Text("No items found"))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10.h,
                          crossAxisSpacing: 10.w,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (_, idx) {
                          final item = filteredItems[idx];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(itemData: item),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(10.r),
                                      child: Image.network(
                                        item['imageUrl'] ?? '',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          color: Colors.black26,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.broken_image,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(item['foodName'] ?? '',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600)),
                                  Text(item['catererName'] ?? '',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp)),
                                  Text(item['price'] ?? '',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
