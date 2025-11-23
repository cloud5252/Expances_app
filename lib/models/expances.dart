import 'package:isar/isar.dart';
part 'expances.g.dart';

@Collection()
class Expances {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;
  Expances({
    required this.amount,
    required this.date,
    required this.name,
  });
}
