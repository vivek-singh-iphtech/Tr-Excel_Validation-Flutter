// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'file_manager_interface.dart';

class FileManager implements FileManagerInterface {

  final String url = 'assets/Payroll_Sheet (7).xlsx';
  @override
  Future<void> downloadFile() async {
   html.AnchorElement(href: url)
  ..download = "Payroll_Sheet (7).xlsx" 
  ..click();
  }
}