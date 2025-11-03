  import 'package:awesome_dialog/awesome_dialog.dart';
  import 'package:flutter/material.dart';

  AwesomeDialog customAlertDialog(BuildContext ctx,
      {String? title,
      String? desc,
      Function()? onConfirm,
      Function()? onCancel,
      String? btnConfirmText,
      String? btnCancelText,
      Color? btnConfirmColor,
      bool headerAnimationLoop = false,
      AnimType animType = AnimType.scale,
      DialogType dialogType = DialogType.infoReverse,
      bool dismissOnTouchOutside = true,
      bool dismissOnBackKeyPress = true,
      bool autoDismiss = true,
      dynamic Function(DismissType)? onDismissCallback}) {
    return AwesomeDialog(
        context: ctx,
        title: title,
        desc: desc,
        btnOkOnPress: onConfirm,
        btnCancelOnPress: onCancel,
        btnOkText: btnConfirmText,
        btnCancelText: btnCancelText,
        btnOkColor: btnConfirmColor,
        headerAnimationLoop: headerAnimationLoop,
        animType: animType,
        dialogType: dialogType,
        dismissOnTouchOutside: dismissOnTouchOutside,
        dismissOnBackKeyPress: dismissOnBackKeyPress,
        autoDismiss: autoDismiss,
        onDismissCallback: onDismissCallback);
  }

  void dismissCustomAlertDialog(BuildContext ctx) {
    AwesomeDialog(context: ctx).dismiss();
  }
