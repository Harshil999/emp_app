import 'package:emp_app/app/moduls/attendence/controller/attendence_controller.dart';
import 'package:get/get.dart';

class AttendanceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendenceController>(
      () => AttendenceController(),
    );
  }
}
