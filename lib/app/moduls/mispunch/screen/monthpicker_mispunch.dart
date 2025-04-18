import 'package:emp_app/app/core/util/app_color.dart';
import 'package:emp_app/app/core/util/sizer_constant.dart';
import 'package:emp_app/app/moduls/mispunch/controller/mispunch_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonthPicker_mispunch extends StatelessWidget {
  final MispunchController controller;
  final ScrollController scrollController_Mispunch;

  const MonthPicker_mispunch({
    Key? key,
    required this.controller,
    required this.scrollController_Mispunch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MispunchController>(
      builder: (controller) {
        // Use WidgetsBinding.instance.addPostFrameCallback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController_Mispunch.hasClients) {
            try {
              // Avoid unnecessary calculations if the scroll position is already correct
              final index = controller.MonthSel_selIndex;
              final itemWidth = 100.0;
              final screenWidth = MediaQuery.of(context).size.width;
              final offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

              if ((offset - scrollController_Mispunch.offset).abs() > 1) {
                scrollController_Mispunch.animateTo(
                  offset,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            } catch (e) {
              print('Scroll error: $e');
            }
          }
        });

        return Center(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              controller: scrollController_Mispunch,
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    controller.upd_MonthSelIndex(index);
                    controller.showHideMsg();
                  },
                  child: Container(
                    width: 100,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: controller.MonthSel_selIndex == index ? AppColor.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      getMonthName(index),
                      style: TextStyle(
                        color: controller.MonthSel_selIndex == index ? AppColor.white : AppColor.black,
                        fontWeight: controller.MonthSel_selIndex == index ? FontWeight.bold : FontWeight.normal,
                        // fontSize: controller.MonthSel_selIndex == index ? 18 : 15,
                        fontSize: controller.MonthSel_selIndex == index ? getDynamicHeight(size: 0.020) : getDynamicHeight(size: 0.017),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String getMonthName(int index) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[index];
  }
}
