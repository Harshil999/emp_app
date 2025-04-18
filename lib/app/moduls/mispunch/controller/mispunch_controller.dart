import 'dart:convert';
import 'package:emp_app/app/core/util/api_error_handler.dart';
import 'package:emp_app/app/moduls/attendence/screen/dropdown_attendance.dart';
import 'package:emp_app/app/core/util/app_string.dart';
import 'package:emp_app/app/core/util/const_api_url.dart';
import 'package:emp_app/app/core/service/api_service.dart';
import 'package:emp_app/app/moduls/bottombar/controller/bottom_bar_controller.dart';
import 'package:emp_app/app/moduls/login/screen/login_screen.dart';
import 'package:emp_app/app/moduls/mispunch/model/mispunchtable_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MispunchController extends GetxController {
  final ApiController apiController = Get.put(ApiController());
  var bottomBarController = Get.put(BottomBarController());
  String tokenNo = '', loginId = '', empId = '';
  var isLoading = false.obs;
  List<MispunchTable> mispunchTable = [];
  RxInt MonthSel_selIndex = (-1).obs;
  String YearSel_selIndex = "";
  var selectedYear = ''.obs;
  var monthScrollController_mispunch = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   setCurrentMonthYear();
    // });
    DateTime now = DateTime.now();
    MonthSel_selIndex.value = now.month - 1;
    YearSel_selIndex = now.year.toString();
    setCurrentMonthYear();
  }

  void setCurrentMonthYear() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    if (monthScrollController_mispunch.hasClients) {
      double itemWidth = 80;
      double screenWidth = Get.context!.size!.width;
      double screenCenter = screenWidth / 2;
      double selectedMonthPosition = MonthSel_selIndex.value * itemWidth;
      double targetScrollPosition = selectedMonthPosition - screenCenter + itemWidth / 2;
      double maxScrollExtent = monthScrollController_mispunch.position.maxScrollExtent;
      double minScrollExtent = monthScrollController_mispunch.position.minScrollExtent;
      if (targetScrollPosition < minScrollExtent) {
        targetScrollPosition = minScrollExtent;
      } else if (targetScrollPosition > maxScrollExtent) {
        targetScrollPosition = maxScrollExtent;
      }

      monthScrollController_mispunch.animateTo(
        targetScrollPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    // });

    DropDownAttendance(
      selValue: YearSel_selIndex,
      onPressed: (index) {
        upd_YearSelIndex(index);
        showHideMsg();
      },
    );

    if (MonthSel_selIndex.value != -1 && YearSel_selIndex.isNotEmpty) {
      getmonthyrempinfotable();
    }

    update();
  }

  @override
  void onClose() {
    // monthScrollController_mispunch.dispose(); //
    super.onClose();
  }
  // void clearData() {
  //   MonthSel_selIndex.value = 0;
  //   YearSel_selIndex = "";
  //   mispunchTable.clear();
  //   isLoading.value = false;
  // }

  void upd_MonthSelIndex(int index) async {
    MonthSel_selIndex.value = index;
    update();
    await getmonthyrempinfotable();
  }

  void upd_YearSelIndex(String index) async {
    YearSel_selIndex = index;
    update();
    await fetchDataIfReady();
  }

  void showHideMsg() {
    String msg = "";
    if (MonthSel_selIndex.value == -1 && YearSel_selIndex.isEmpty) {
      msg = "Please select Month and Year!";
    } else if (MonthSel_selIndex.value == -1 && YearSel_selIndex.isNotEmpty) {
      msg = "Please select Month!";
    } else if (MonthSel_selIndex.value != -1 && YearSel_selIndex.isEmpty) {
      msg = "Please select Year!";
    }

    if (msg.isNotEmpty) {
      Get.rawSnackbar(message: msg);
    }
  }

  Future fetchDataIfReady() async {
    if (MonthSel_selIndex.value != -1 && YearSel_selIndex.isNotEmpty) {
      await getmonthyrempinfotable();
    }
  }

  Future<List<MispunchTable>> getmonthyrempinfotable() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      isLoading.value = true;
      String url = ConstApiUrl.empMispunchDetailAPI;
      loginId = await pref.getString(AppString.keyLoginId) ?? "";
      tokenNo = await pref.getString(AppString.keyToken) ?? "";

      String monthYr = getMonthYearFromIndex(MonthSel_selIndex.value, YearSel_selIndex);

      var jsonbodyObj = {"loginId": loginId, "empId": empId, "monthYr": monthYr};

      // var empmonthyrtable = await apiController.getDynamicData(url, tokenNo, jsonbodyObj);
      var decodedResp = await apiController.parseJsonBody(url, tokenNo, jsonbodyObj);
      ResponseMispunchData detailResponse = ResponseMispunchData.fromJson(jsonDecode(decodedResp));

      if (detailResponse.statusCode == 200) {
        if (detailResponse.data != null && detailResponse.data!.isNotEmpty) {
          isLoading.value = false;
          mispunchTable = detailResponse.data!;
          update();
          return mispunchTable;
        } else {
          mispunchTable = [];
        }
        update();
      } else if (detailResponse.statusCode == 401) {
        pref.clear();
        Get.offAll(const LoginScreen());
        // Get.rawSnackbar(message: finalData.data['message']);
        Get.rawSnackbar(message: 'Your session has expired. Please log in again to continue');
      } else if (detailResponse.statusCode == 400) {
        isLoading.value = false;
        mispunchTable = [];
        //Get.rawSnackbar(message: "No data found!");
      } else {
        Get.rawSnackbar(message: "Somethin g went wrong");
      }
      update();
    } catch (e) {
      isLoading.value = false;
      update();
      ApiErrorHandler.handleError(
        screenName: "MispunchScreen",
        error: e.toString(),
        loginID: pref.getString(AppString.keyLoginId) ?? '',
        tokenNo: pref.getString(AppString.keyToken) ?? '',
        empID: pref.getString(AppString.keyEmpId) ?? '',
      );
    }
    return [];
  }

  String getMonthYearFromIndex(int index, String year) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if (index >= 0 && index < months.length && year.isNotEmpty && year != "") {
      return '${months[index]}${year.substring(year.length - 2)}'; // Format as 'Jan24'
    }
    return 'Select year and month';
  }

  void resetData() {
    mispunchTable.clear(); // Clear the attendance detail table
    isLoading.value = false; // Reset loader state
    DateTime now = DateTime.now();
    MonthSel_selIndex.value = now.month - 1; // Month index is 0-based
    YearSel_selIndex = now.year.toString();
    update(); // Notify listeners
  }
}
