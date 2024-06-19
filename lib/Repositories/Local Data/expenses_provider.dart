import 'package:hive/hive.dart';
import 'expenses_list_element.dart';

class ExpensesProvider {
  final Box<ExpensesListElementModel> _expensesBox;

  ExpensesProvider(this._expensesBox);

  // Create
  Future<void> addExpense(ExpensesListElementModel expense) async {
    await _expensesBox.add(expense);
  }

  // Read all
  List<ExpensesListElementModel> getAllExpenses() {
    return _expensesBox.values.toList();
  }

  // Read by id
  ExpensesListElementModel? getExpenseById(String id) {
    try {
      return _expensesBox.values.firstWhere((element) => element.localId == id);
    } catch (e) {
      return null;
    }
  }

  // Update
  Future<void> updateExpense(String id, ExpensesListElementModel updatedExpense) async {
    final key = _expensesBox.keys.firstWhere((element) {
      final expense = _expensesBox.get(element);
      return expense?.localId == id;
    }, orElse: () => null);

    if (key != null) {
      await _expensesBox.put(key, updatedExpense);
    }
  }

  Future<void> deleteExpense(String id) async {
    final key = _expensesBox.keys.firstWhere((element) {
      final expense = _expensesBox.get(element);
      return expense?.localId == id;
    }, orElse: () => null);

    if (key != null) {
      await _expensesBox.delete(key);
    }
  }

  Future<void> setForDeletion(String id) async {
  final key = _expensesBox.keys.firstWhere((element) {
    final expense = _expensesBox.get(element);
    return expense?.localId == id;
  }, orElse: () => null);

  if (key != null) {
    final expense = _expensesBox.get(key);
    if (expense != null) {
      expense.toBeDeleted = true;
      await _expensesBox.put(key, expense);
    }
  }
}

  // DeleteAll
  Future<void> deleteAllExpense() async {
    await _expensesBox.clear();
  }
}