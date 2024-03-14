import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'file_manager_interface.dart';
// import 'package:permission_handler/permission_handler.dart'; 

class FileManager implements FileManagerInterface {

  @override
  Future<void> downloadFile() async {
    try {
      // Load file from assets
      final ByteData data = await rootBundle.load('assets/Payroll_Sheet (7).xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      
      // Get documents directory
      final String dir = (await getApplicationDocumentsDirectory()).path;
      
      // Specify the path in the documents directory
      final String path = "/storage/emulated/0/Download/Payroll_Sheet (7).xlsx";
      
      // Write bytes to file
      final File file = File(path);
      await file.writeAsBytes(bytes);
      
      // Log successful file save
      log('File saved at $path');
    } catch (e) {
      // Log any errors encountered
      log('Error saving file: $e');
    }
  }
}
