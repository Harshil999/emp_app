import 'package:emp_app/app/core/util/app_color.dart';
import 'package:emp_app/app/core/util/app_font_name.dart';
import 'package:emp_app/app/core/util/app_image.dart';
import 'package:emp_app/app/core/util/app_string.dart';
import 'package:emp_app/app/core/util/app_style.dart';
import 'package:emp_app/app/core/util/sizer_constant.dart';
import 'package:emp_app/app/moduls/admitted%20patient/controller/adpatient_controller.dart';
import 'package:emp_app/app/moduls/admitted%20patient/screen/adpatient_screen.dart';
import 'package:emp_app/app/moduls/bottombar/controller/bottom_bar_controller.dart';
import 'package:emp_app/app/moduls/dashboard/controller/dashboard_controller.dart';
import 'package:emp_app/app/moduls/notification/screen/notification_screen.dart';
import 'package:emp_app/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class IpdDashboardScreen extends StatefulWidget {
  const IpdDashboardScreen({Key? key}) : super(key: key);

  @override
  State<IpdDashboardScreen> createState() => _IpdDashboardScreenState();
}

class _IpdDashboardScreenState extends State<IpdDashboardScreen> {
  final adPatientController = Get.put(AdPatientController());

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await adPatientController.fetchDeptwisePatientList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdPatientController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.white,
          drawer: Drawer(
            backgroundColor: AppColor.white,
            child: ListView(
              children: [
                const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    focusNode: controller.focusNode,
                    cursorColor: AppColor.grey,
                    controller: controller.textEditingController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.lightgrey1, width: 1.0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: AppColor.lightgrey1,
                        ),
                      ),
                      prefixIcon: Icon(Icons.search, color: AppColor.lightgrey1),
                      suffixIcon: controller.hasFocus
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: AppColor.lightgrey1,
                              ),
                              onPressed: () {
                                controller.textEditingController.clear();
                                controller.filterSearchAdPatientResults('');
                              },
                            )
                          : null,
                      hintText: AppString.search,
                      hintStyle: TextStyle(
                        color: AppColor.lightgrey1,
                        fontFamily: CommonFontStyle.plusJakartaSans,
                      ),
                      filled: true,
                      focusColor: AppColor.originalgrey,
                      fillColor: AppColor.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                    ),
                    onChanged: (value) {
                      controller.filterSearchAdPatientResults(value);
                    },
                  ),
                ),
                GetBuilder<AdPatientController>(
                  builder: (controller) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      shrinkWrap: true,
                      itemCount: controller.filteredList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (controller.isPresViewerNavigating.value) return;
                            controller.isPresViewerNavigating.value = true;
                            Navigator.pop(context);
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: AdpatientScreen(),
                              withNavBar: false,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            ).then((value) async {
                              final bottomBarController = Get.put(BottomBarController());
                              bottomBarController.currentIndex.value = -1;
                              bottomBarController.persistentController.value.index = 0;
                              bottomBarController.currentIndex.value = 0;
                              bottomBarController.isIPDHome.value = true;
                              hideBottomBar.value = true;
                              var dashboardController = Get.put(DashboardController());
                              await dashboardController.getDashboardDataUsingToken();
                            });
                            controller.isPresViewerNavigating.value = false;
                          },
                          child: SizedBox(
                            height: getDynamicHeight(size: 0.040),
                            child: ListTile(
                              leading: Image.asset(
                                controller.filteredList[index]['image'],
                                height: getDynamicHeight(size: 0.025),
                                width: 25,
                                color: AppColor.primaryColor,
                              ),
                              title: Text(
                                controller.filteredList[index]['label'],
                                style: TextStyle(
                                  // fontSize: 16.0,
                                  fontSize: getDynamicHeight(size: 0.018),
                                  fontFamily: CommonFontStyle.plusJakartaSans,
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // controller.payrolListOnClk(index, context);
                                    hideBottomBar.value = true;
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: AdpatientScreen(),
                                      withNavBar: false,
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    ).then((value) async {
                                      final bottomBarController = Get.put(BottomBarController());
                                      bottomBarController.currentIndex.value = -1;
                                      bottomBarController.persistentController.value.index = 0;
                                      bottomBarController.currentIndex.value = 0;
                                      bottomBarController.isIPDHome.value = true;
                                      hideBottomBar.value = true;
                                      var dashboardController = Get.put(DashboardController());
                                      await dashboardController.getDashboardDataUsingToken();
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),
          appBar: AppBar(
            title: Text(AppString.ipd, style: AppStyle.primaryplusw700),
            backgroundColor: AppColor.white,
            centerTitle: true,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Image.asset(
                    AppImage.drawer,
                    width: getDynamicHeight(size: 0.022),
                    color: AppColor.black,
                  ),
                );
              },
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    // Get.to(() => NotificationScreen());
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: NotificationScreen(),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    ).then((value) async {
                      await adPatientController.fetchDeptwisePatientList();
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        AppImage.notification,
                        width: getDynamicHeight(size: 0.022),
                      ),
                      Positioned(
                        right: -2,
                        top: -6,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '', //controller.notificationCount,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: GetBuilder<AdPatientController>(
            builder: (controller) {
              if (controller.isLoading) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: getDynamicHeight(size: 0.102),
                  ),
                  child: Center(child: CircularProgressIndicator()),
                ); // 🔹 Jab tak data load ho raha hai
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: 1,
                itemBuilder: (context, index) {
                  return _buildPatientCard(AppString.admittedPatient, controller.patientsData.length, context, index);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPatientCard(String title, int count, BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: AdpatientScreen(),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        ).then((value) async {
          final controller = Get.put(AdPatientController());
          controller.sortBySelected = -1;
          await controller.resetForm();
          await _fetchData();
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.currentIndex.value = 0;
          bottomBarController.isIPDHome.value = true;
          hideBottomBar.value = false;
          var dashboardController = Get.put(DashboardController());
          await dashboardController.getDashboardDataUsingToken();
        });
      },
      child: Card(
        color: AppColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColor.teal, width: 1),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title, // Dynamic Title
                        style: TextStyle(fontSize: Sizes.px18, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  SizedBox(height: Sizes.px8),
                  Text(
                    "$count", // Dynamic Count
                    style: TextStyle(fontSize: Sizes.px20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Image.asset('assets/image/AdPatient.png', // Image ko bhi dynamic kar sakte ho agar chaho
                  height: Sizes.px40,
                  width: Sizes.px40,
                  color: AppColor.teal),
              // Icon(
              //   Icons.person, // Icon ko bhi dynamic kar sakte ho agar chaho
              //   size: Sizes.px40,
              //   color: AppColor.teal,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
