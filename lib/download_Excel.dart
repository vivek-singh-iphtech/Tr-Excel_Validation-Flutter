import 'file_manager/file_manager.dart'; 
import 'package:flutter/material.dart';

class DownloadExcel extends StatefulWidget {
  const DownloadExcel({Key? key}) : super(key: key);

  @override
  State<DownloadExcel> createState() => _DownloadExcelState();
}

class _DownloadExcelState extends State<DownloadExcel> {
  final manager = FileManager();
  bool fileDownloaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Download'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await manager.downloadFile();
                setState(() {
                  fileDownloaded = true;
                });
              },
              child: const Text('Download Excel'),
            ),
            if (fileDownloaded)
              const Column(
                children: [
                  SizedBox(height: 20),
                  Text('File downloaded!'),
                  // ElevatedButton(
                  //   onPressed: () {
                   
                  //   },
                  //   child: const Text('Check Downloads'),
                  // ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
