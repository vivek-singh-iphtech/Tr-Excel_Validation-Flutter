import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'file_manager_interface.dart';
import 'package:open_file_plus/open_file_plus.dart';

class FileManager implements FileManagerInterface {
  @override
  Future<void> downloadFile() async {
    try {
   // Load file from assets
      final ByteData data = await rootBundle.load('assets/Payroll_Sheet (7).xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
 
      String filename = "Payroll_Sheet (7).xlsx";
      
      // Specify the path in the documents directory
      String path = "/storage/emulated/0/Download/$filename";
      
      // Check if the file already exists
      int fileIndex = 1;
      while (await File(path).exists()) {
        // If file exists, generate a new filename
        filename = "Payroll_Sheet (7)_$fileIndex.xlsx";
        path = "/storage/emulated/0/Download/$filename";
        fileIndex++;
      }
      
      // Write bytes to file
      final File file = File(path);
      await file.writeAsBytes(bytes);
      
      log('$file.path');
        await OpenFile.open(path);
    } catch (e) {
    
      log('Error saving file: $e');
     
    }
  }



}
