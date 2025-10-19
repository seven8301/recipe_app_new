import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
const SERVER_API_URL = "http://10.0.2.2:7777";

final logger = Logger(
  printer: PrettyPrinter(lineLength: 20),
  output: DebugPrintConsoleOutput(),
);

class DebugPrintConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final element in event.lines) {
      debugPrint(element);
    }
  }
}