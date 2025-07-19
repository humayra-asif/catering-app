import 'dart:async';
import 'package:capp/screens/user/profile.dart';
import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key, required String userId});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<String> bannerImages = [];
  List<Map<String, dynamic>> catererItems = [];
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
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (bannerImages.isEmpty) return;

      _currentPage++;
      if (_currentPage >= bannerImages.length) {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void fetchBannerImages() async {
    final snapshot = await FirebaseFirestore.instance.collection('banners').get();
    List<String> tempImages = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data is Map<String, dynamic> && data.containsKey('imageUrl')) {
        final urls = data['imageUrl'];
        if (urls is List) {
          tempImages.addAll(urls.whereType<String>().where((url) => url.isNotEmpty));
        }
      }
    }

    setState(() {
      bannerImages = tempImages;
    });
  }

  void fetchCatererItems() async {
    final snapshot = await FirebaseFirestore.instance.collection('catererItems').limit(8).get();
    setState(() {
      catererItems = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'foodName': data['foodName'] ?? '',
          'price': data['price'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
        };
      }).toList();
      filteredItems = List.from(catererItems);
    });
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = catererItems.where((item) {
        return item['foodName'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.red,
        elevation: 0,
        title: Image.asset(
          'assets/images/CuberLogo.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Search bar and profile button
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
                            const Icon(Icons.manage_search_outlined, color: Colors.black54),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextField(
                                onChanged: _filterItems,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  hintText: "Search...",
                                  hintStyle: TextStyle(color: Colors.black54),
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
                          MaterialPageRoute(builder: (_) => const EditProfileScreen(userId: '')),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors2.grey,
                        child: const Icon(Icons.person, color: Colors.black, size: 30),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Banner with autoplay + dot indicator
                bannerImages.isEmpty
                    ? SizedBox(
                        height: 300.h,
                        //width: double.infinity,
                        child: const Center(child: Text("No banners found")),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 200.h,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: bannerImages.length,
                              onPageChanged: (index) {
                                setState(() => _currentPage = index);
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.network(
                                    bannerImages[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppColors.red,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image, color: Colors.white),
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
                              activeDotColor: AppColors.red,
                              dotHeight: 8,
                              dotWidth: 8,
                            ),
                          ),
                        ],
                      ),

                SizedBox(height: 30.h),

                Text("Popular Items",
                    style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                const Divider(),
                SizedBox(height: 16.h),

                // Grid of popular items
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredItems.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Container(
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
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.network(
                                item['imageUrl'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.black26,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(item['foodName'],
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                          Text(item['price'], style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
