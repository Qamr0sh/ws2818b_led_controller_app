import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Resources/app_colors.dart';
import '../Resources/app_theme.dart';

Widget customButton({
  required String label,
  required Function onTap,
  Color? backgroundColor,
  Color? labelColor,
  double? fontSize,
  RxBool? isLoading,
}) {
  Widget buildContent(bool loading) {
    return GestureDetector(
      onTap: loading ? null : () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(41),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: Get.width,
        child: Center(
          child: loading
              ? SizedBox(
            height: fontSize == null? 20: (fontSize + 7),
            width: fontSize == null? 20: (fontSize + 7),
            child: const CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.white,
            ),
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: appTheme.textTheme.bodySmall?.copyWith(
                  color: labelColor ?? AppColors.black,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if (isLoading != null) {
    return Obx(() => buildContent(isLoading.value));
  } else {
    return buildContent(false);
  }
}
