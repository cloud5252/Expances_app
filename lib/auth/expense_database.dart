import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expances.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expances> _allExpaces = [];
  List<int> monthlySummary = List.filled(31, 0);

  // ExpenseDatabase main
  Set<String> countedDays = {}; // format: "2025-06-01"

  void addItem(DateTime date) {
    String key = "${date.year}-${date.month}-${date.day}";

    // ListTile ke liye price add hoga waisa ka waisa
    // BarGraph ke liye sirf check karo
    if (!countedDays.contains(key)) {
      countedDays.add(
        key,
      ); // bar graph main sirf ek dafa count add hoga
      // int month = date.month;
      int day = date.day - 1;

      // monthlySummary sirf count track kare
      monthlySummary[day] = monthlySummary[day] + 1;
    }

    notifyListeners();
  }

  /*
  SETUP
  */
  // initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpancesSchema], directory: dir.path);
  }

  /*
  GETTER
  */
  List<Expances> get allexpaces => _allExpaces;
  /*
  OPRATIONS
  */
  Future<void> createExpances(Expances newexapaces) async {
    await isar.writeTxn(() => isar.expances.put(newexapaces));
    await readExpances();
  }

  Future<void> readExpances() async {
    List<Expances> fetchExpances = await isar.expances
        .where()
        .findAll();
    _allExpaces.clear();
    _allExpaces.addAll(fetchExpances);
    notifyListeners();
  }

  Future<void> updateExpaces(int id, Expances updateExpances) async {
    updateExpances.id = id;
    await isar.writeTxn(() => isar.expances.put(updateExpances));
    await readExpances();
  }

  Future<void> deleteExpances(int id) async {
    await isar.writeTxn(() => isar.expances.delete(id));
    await readExpances();
  }

  /*
  HELPER
  */

  Future<Map<int, double>> calculateMonthlyTotal() async {
    await readExpances();
    Map<int, double> monthlyTotals = {};
    for (var expense in allexpaces) {
      int month = expense.date.month;
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }
      monthlyTotals[month] = monthlyTotals[month]! + 1;
      // monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }
    return monthlyTotals;
  }

  int getFirstExpenseMonth() {
    if (_allExpaces.isEmpty) return DateTime.now().month;
    _allExpaces.sort((a, b) => a.date.compareTo(b.date));
    return _allExpaces.first.date.month;
  }

  int getFirstExpenseYear() {
    if (_allExpaces.isEmpty) return DateTime.now().year;
    _allExpaces.sort((a, b) => a.date.compareTo(b.date));
    return _allExpaces.first.date.year;
  }

  int getLastExpenseMonth() {
    if (_allExpaces.isEmpty) return DateTime.now().month;
    _allExpaces.sort((a, b) => a.date.compareTo(b.date));
    return _allExpaces.last.date.month;
  }

  int getLastExpenseYear() {
    if (_allExpaces.isEmpty) return DateTime.now().year;
    _allExpaces.sort((a, b) => a.date.compareTo(b.date));
    return _allExpaces.last.date.year;
  }
}
