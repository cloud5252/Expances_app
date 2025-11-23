import 'package:intl/intl.dart';

double converstringToDobble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// String formateAmount(double amount) {
//   final formant = NumberFormat.currency(
//     locale: 'en_US',
//     symbol: '\$',
//     decimalDigits: 2,
//   );
//   return formant.format(amount);
// }
String formateAmount(double amount) {
  final format = NumberFormat.currency(
    locale: 'ur_PK', // Pakistan style formatting
    symbol: '', // No currency symbol
    decimalDigits: 0, // No decimal points
  );

  return format.format(amount);
}

int caculateMonthCount(
  int startYear,
  startMonth,
  currentyear,
  currentMonth,
) {
  int monthCount =
      (currentyear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}
