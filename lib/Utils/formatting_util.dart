import 'package:intl/intl.dart';

class FormattingUtility{
  String getDateStringFromLocalDate(Map<String, dynamic> localDateFormatMap){
    int year = localDateFormatMap['year'];
    int month = localDateFormatMap['monthValue'];
    int dayOfMonth = localDateFormatMap['dayOfMonth'];
    DateTime date = DateTime(year, month, dayOfMonth);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  DateTime getDateFromLocalDate(Map<String, dynamic> localDateFormatMap){
    int year = localDateFormatMap['year'];
    int month = localDateFormatMap['monthValue'];
    int dayOfMonth = localDateFormatMap['dayOfMonth'];
    return DateTime(year, month, dayOfMonth);
  }

  String getDateStringFromDateTime(DateTime dateTime){
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  DateTime getDateInDateTimeFormat(String dateString){
    return DateFormat('dd-MM-yyyy').parse(dateString);
  }
}