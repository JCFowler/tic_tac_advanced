import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../dialogs/dialogs/new_update.dart';

import '../services/fire_service.dart';

bool wasChecked = false;

checkVersion(BuildContext context) async {
  final fireService = FireService();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  final version = await fireService.getVersion(isAndriod: Platform.isAndroid);

  if (version != null) {
    // version.version = '2.0.0';
    if (version.isVersionNumberGreater(packageInfo.version)) {
      if (context.mounted) {
        showNewUpdateDialog(context).then((value) {
          LaunchReview.launch(
            androidAppId: version.link,
            iOSAppId: version.link,
            writeReview: false,
          );
        });
      }
    }
  }
}
