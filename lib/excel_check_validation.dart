import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:myapp/constants.dart';

class ExcelCheckValidation extends StatefulWidget {
  const ExcelCheckValidation({Key? key}) : super(key: key);

  @override
  _ExcelCheckValidationState createState() => _ExcelCheckValidationState();
}

class _ExcelCheckValidationState extends State<ExcelCheckValidation> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _errorNotifier = ValueNotifier<String>('');

  final RegExp employeeRegExp = RegExp(r'^[a-zA-Z0-9]+$');

  final RegExp numberCheck = RegExp(r'^[0-9]+$');

  bool isAlphabet(String str) {
    final RegExp alphaRegex = RegExp(r'^[a-zA-Z]+$');
    return alphaRegex.hasMatch(str.trim());
  }

  //It should be 11 characters long.
  //The first four characters should be upper case alphabets.
  //The fifth character should be 0.
  //The last six characters are usually numeric, but can also be alphabetic.
  final RegExp ifsc_Code = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  int serialNumberOfRow = 0;

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;

    String formattedDay = day < 10 ? '0$day' : '$day';
    String formattedMonth = month < 10 ? '0$month' : '$month';

    return '$formattedDay-$formattedMonth-$year';
  }

  Future<void> _importExcel() async {
    serialNumberOfRow = 0;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      try {
        List<PlatformFile> files = result.files;
        PlatformFile file = files.first;
        var bytes = file.bytes;

        Excel excel = Excel.decodeBytes(bytes!);

        List<Map<String, String>> allFailedFields = [];

        List<int> AllRowNumbers = [];

        for (var table in excel.tables.keys) {
          var rows = excel.tables[table]!.rows;
          var columns =
              rows.first.map((cell) => cell!.value.toString()).toList();

          // Skip the first row (column names)
          bool isFirstRow = true;

          for (var row in rows) {
            if (isFirstRow) {
              isFirstRow = false;
              continue; // Skip the first row
            }

            // Validate each row and extract cell values || also give empty values to null cell
            List<dynamic> rowData =
                row.map((cell) => (cell?.value ?? '').toString()).toList();

            // check if there is all empty cell value in a
            bool allCellsEmpty = rowData.every((cell) => cell.isEmpty);

            //counter for Row serial Number
            serialNumberOfRow++;

            // if there is no all empty cell row validate
            if (!allCellsEmpty) {
              Map<String, String> failedFields = _validateRow(rowData, columns);

              if (failedFields.isNotEmpty) {
                allFailedFields.add(failedFields);
                AllRowNumbers.add(serialNumberOfRow);
              }
            }
          }
        }

        if (allFailedFields.isEmpty) {
          _isValidNotifier.value = true;
        } else {
          _errorNotifier.value = 'Validation failed for multiple rows:';
          _errorNotifier.value += '\n';
          for (var i = 0; i < allFailedFields.length; i++) {
            var failedFields = allFailedFields[i];
            var rowNum = AllRowNumbers[i];

            _errorNotifier.value += '\nErrors in Row $rowNum :\n';

            failedFields.forEach((columnName, error) {
              _errorNotifier.value += '$columnName: $error.\n';
            });
          }
        }
      } catch (e) {
        _errorNotifier.value = 'Error occurred while importing Excel: $e.';
      }
    }
  }

  Map<String, String> _validateRow(List<dynamic> row, List<String> columns) {
    Map<String, String> failedFields = {};

    for (var i = 0; i < row.length; i++) {
      if (row[i].toString().isEmpty) {
        failedFields[columns[i]] = '${columns[i]} cannot be empty';
      }

      if (columns[i] == strings.employeeID && row[i].toString().isNotEmpty) {
        if (!employeeRegExp.hasMatch(row[i])) {
          failedFields[columns[i]] = '${columns[i]} should be alpha-numeric';
        }
      }

      //Validate all Number Data
      if (columns[i] == strings.totalWorkingDays ||
          columns[i] == strings.paidDays ||
          columns[i] == strings.actualGross ||
          columns[i] == strings.earnedGross ||
          columns[i] == strings.tax ||
          columns[i] == strings.pF ||
          columns[i] == strings.ESIC ||
          columns[i] == strings.Bonus ||
          columns[i] == strings.Net_Pay) {
        try {
          int checkOnlyNumberData = int.parse(row[i].toString());
          if (checkOnlyNumberData < 0) {
            failedFields[columns[i]] = '${columns[i]} cant be Negative';
          }
        } catch (e) {
          if (row[i].toString().isNotEmpty) {
            failedFields[columns[i]] = '${columns[i]} must be valid integer';
          }
        }
      }

      //Validate Beneficiary_Name
      if (columns[i] == strings.Beneficiary_Name) {
        if (!isAlphabet(row[i].toString())) {
          if (row[i].toString().isNotEmpty) {
            failedFields[columns[i]] =
                '${columns[i]} should only contain alphabets';
          }
        }
      }

      //Validate Beneficiary_Account_No and Debit_Account_No
      if (columns[i] == strings.Beneficiary_Account_No ||
          columns[i] == strings.Debit_Account_No) {
        try {
          int checkOnlyNumberData = int.parse(row[i].toString());
          if (checkOnlyNumberData < 0) {
            failedFields[columns[i]] = '${columns[i]} cant be Negative';
          }
        } catch (e) {
          if (row[i].toString().isNotEmpty) {
            failedFields[columns[i]] = '${columns[i]} must be valid integer';
          }
        }
      }

      // Validate IFSC Code
      if (columns[i] == strings.IFSC_Code) {
        if (!ifsc_Code.hasMatch(row[i].toString())) {
          if (row[i].toString().isNotEmpty) {
            failedFields[columns[i]] =
                '${columns[i]} is Invalid. Please check again';
          }
        }
      }

      //Validate Date
      if (columns[i] == strings.Date) {
        if (row[i].toString().isNotEmpty) {
          bool? isValidDate(String dateString) {
            // Check for valid format
            RegExp dateRegex = RegExp(r'^\d{2}-\d{2}-\d{4}$');
            if (!dateRegex.hasMatch(dateString)) {
              return false;
            }

            List<String> parts = dateString.split('-');
            int? day = int.tryParse(parts[0]);
            int? month = int.tryParse(parts[1]);
            int? year = int.tryParse(parts[2]);

            // Check for non-negative values
            if (day! <= 0 || month! <= 0 || year! <= 0) {
              failedFields[columns[i]] = '${columns[i]} cant be negative';
            }

            // Check for invalid month
            if (month! > 12) {
              failedFields[columns[i]] = 'Invalid Month';
            }

            if (day > 31 ||
                (month == 2 && day > 29) || // February
                ((month == 4 || month == 6 || month == 9 || month == 11) &&
                    day > 30) || // April, June, September, November
                (month == 2 && year! % 4 != 0 && day > 28)) {
              // February in non-leap years
              failedFields[columns[i]] =
                  'Invalid Day. Please enter a valid Day';
            }
            return true;
          }

          if (!(isValidDate(formatDate(row[i].toString()))!)) {
            failedFields[columns[i]] = '${columns[i]} is Invalid';
          }
        }
      }

      //Validate status
      if (columns[i] == strings.Status) {
        if (row[i].toString().toLowerCase() == strings.paid ||
            row[i].toString().toLowerCase() == strings.unpaid) {
          if (row[i].toString().isNotEmpty) {
            failedFields[columns[i]] =
                '${columns[i]} is Invalid. Please check again';
          }
        }
      }
    }

    return failedFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Import'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _importExcel,
              child: const Text('Import Excel'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isValidNotifier,
              builder: (context, isValid, child) {
                if (isValid) {
                  return ElevatedButton(
                    onPressed: () {
                      
                    },
                    child: const Text('Next'),
                  );
                }
                return const SizedBox(); 
              },
            ),
            ValueListenableBuilder<String>(
              valueListenable: _errorNotifier,
              builder: (context, error, child) {
                if (error.isNotEmpty) {
                  return Text(error);
                }
                return const SizedBox(); 
              },
            ),
          ],
        ),
      ),
    );
  }
}
