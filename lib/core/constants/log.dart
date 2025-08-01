import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class MyLogger {
  final Logger logger = Logger();


  static void writeLog(String message) {
     if (kDebugMode) {
        log(message);
     }
  }

}
