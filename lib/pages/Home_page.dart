import 'package:expances_tracker/bar_graph/bar_graph.dart';
import 'package:expances_tracker/component/My_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expances.dart';
import '../auth/expense_database.dart';
import '../helper/helper_function.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController amountController =
      TextEditingController();

  Future<Map<int, double>>? monthlyTotalFuture;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(
      context,
      listen: false,
    ).readExpances();
    refreshGraphData();
    super.initState();
  }

  void refreshGraphData() {
    monthlyTotalFuture = Provider.of<ExpenseDatabase>(
      context,
      listen: false,
    ).calculateMonthlyTotal();
  }

  void openNewExpensesBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Expenses'),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              nameController.clear();
              amountController.clear();
            },
            child: const Text('Cancel'),
          ),
          createNewExapancesButton(),
        ],
      ),
    );
  }

  void openeditBox(Expances expence) {
    final existingName = expence.name;
    final existingAmount = expence.amount.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: existingName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  hintText: existingAmount,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              nameController.clear();
              amountController.clear();
            },
            child: const Text('Cancel'),
          ),
          editExpancesButton(expence),
        ],
      ),
    );
  }

  void openDeleteBox(Expances expence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              nameController.clear();
              amountController.clear();
            },
            child: const Text('Cancel'),
          ),
          DeleteExpancesButton(expence.id),
        ],
      ),
    );
  }

  Widget createNewExapancesButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          final expense = Expances(
            name: nameController.text,
            amount: converstringToDobble(amountController.text),
            date: DateTime.now(),
          );
          await context.read<ExpenseDatabase>().createExpances(
            expense,
          );
          refreshGraphData();
        }

        nameController.clear();
        amountController.clear();
      },
      child: const Text('Save'),
    );
  }

  Widget editExpancesButton(Expances expences) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expances updateExpances = Expances(
            amount: amountController.text.isNotEmpty
                ? converstringToDobble(amountController.text)
                : expences.amount,
            date: DateTime.now(),
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expences.name,
          );
          int existingId = expences.id;
          await context.read<ExpenseDatabase>().updateExpaces(
            existingId,
            updateExpances,
          );
          refreshGraphData();

          // Controllers clear karna zaroori hai
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  Widget DeleteExpancesButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpances(id);
        refreshGraphData();
      },
      child: const Text('Delete'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        int startMonth = value.getFirstExpenseMonth();
        int startYear = value.getFirstExpenseYear();

        int endMonth = value.getLastExpenseMonth();
        int endYear = value.getLastExpenseYear();

        // Month Count Calculate
        int monthCount = caculateMonthCount(
          startYear,
          startMonth,
          endYear,
          endMonth,
        );
        if (monthCount <= 0) monthCount = 1;

        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.green,
            title: const Text(
              'Expense Tracker',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green.shade400,
            onPressed: openNewExpensesBox,
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 300,
                child: FutureBuilder<Map<int, double>>(
                  future: monthlyTotalFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: Text('loading..'));
                    } else if (snapshot.hasData) {
                      final monthlyTotals = snapshot.data!;

                      List<double> monthlySummary = List.generate(
                        monthCount,
                        (index) {
                          int month =
                              ((startMonth - 1 + index) % 12) + 1;
                          return monthlyTotals[month] ?? 0.0;
                        },
                      );
                      return BarGraph(
                        monthlySummary: monthlySummary,
                        startMonth: startMonth,
                      );
                    } else {
                      return const Center(child: Text('No data'));
                    }
                  },
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: value.allexpaces.length,
                  itemBuilder: (context, index) {
                    Expances individualExpences =
                        value.allexpaces[index];

                    return MyListTile(
                      title: individualExpences.name,
                      trailing: formateAmount(
                        individualExpences.amount,
                      ),
                      onEditPressed: (BuildContext context) =>
                          openeditBox(individualExpences),
                      onDeletePressed: (BuildContext context) =>
                          openDeleteBox(individualExpences),
                      date: DateFormat(
                        'dd/MM/yyyy',
                      ).format(individualExpences.date),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
