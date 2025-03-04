import 'expenses_list_element.dart';
import 'package:hive/hive.dart';

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
        final updatedExpense = expense.copyWith(toBeDeleted: true);
        await _expensesBox.put(key, updatedExpense);
      }
    }
  }

  Future<void> setAllForDeletion() async {
    final allKeys = _expensesBox.keys.toList();

    for (var key in allKeys) {
      final expense = _expensesBox.get(key);
      if (expense != null) {
        final updatedExpense = expense.copyWith(toBeDeleted: true);
        await _expensesBox.put(key, updatedExpense);
      }
    }
  }

  // DeleteAll
  Future<void> deleteAllExpense() async {
    await _expensesBox.clear();
  }
}