import 'package:intl/intl.dart';

class FormattingUtility{
  String getDate(Map<String, dynamic> localDateFormatMap){
    int year = localDateFormatMap['year'];
    int month = localDateFormatMap['monthValue'];
    int dayOfMonth = localDateFormatMap['dayOfMonth'];
    DateTime date = DateTime(year, month, dayOfMonth);
    return DateFormat('dd-MM-yyyy').format(date);

  }
}