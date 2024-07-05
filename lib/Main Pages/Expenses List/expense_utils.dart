import '../../Repositories/Local Data/expenses_list_element.dart';
import '../../Authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'add_expense_page.dart';

String calculatePrice(String input) {
  input = input.replaceAll(',', '.');
  if (input.contains('/')) {
    var parts = input.split('/');
    if (parts.length == 2) {
      double num = double.tryParse(parts[0]) ?? 0;
      double denom = double.tryParse(parts[1]) ?? 1;
      return (num / denom).toString();
    }
  } else if (input.contains('*')) {
    var parts = input.split('*');
    if (parts.length == 2) {
      double num1 = double.tryParse(parts[0]) ?? 0;
      double num2 = double.tryParse(parts[1]) ?? 0;
      return (num1 * num2).toString();
    }
  }
  return double.tryParse(input)?.toString() ?? '0.0';
}

void resetFields(AddExpensePageState state) {
  state.data = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  state.sklep = '';
  state.kategoria = '';
  state.produkt = '';
  state.ilosc = 1;
  state.cena = 0.0;
  state.miara = null;
  state.miaraUnit = null;
  state.iloscWOpakowaniu = null;
  state.kosztDostawy = null;
  state.zwrot = false;
  state.link = '';
  state.komentarz = '';
}

Future<void> saveExpense(AddExpensePageState state, GlobalKey<FormState> formKey, ExpensesListElementModel? expense, Function loadOrRefreshLocalData, GlobalKey<NavigatorState> navigatorKey, ValueNotifier<String> shopNotifier, ValueNotifier<String> categoryNotifier, ValueNotifier<String> productNotifier) async {
  if (formKey.currentState?.validate() ?? false) {
    formKey.currentState?.save();

    state.sklep = shopNotifier.value.isEmpty ? state.sklep : shopNotifier.value;
    state.kategoria = categoryNotifier.value.isEmpty ? state.kategoria : categoryNotifier.value;
    state.produkt = productNotifier.value.isEmpty ? state.produkt : productNotifier.value;

    bool isUpdating = expense != null;
    String newLocalId = isUpdating ? expense.localId : const Uuid().v4();

    final newExpense = ExpensesListElementModel(
      localId: newLocalId,
      firebaseId: expense?.firebaseId,
      data: state.data,
      sklep: state.sklep,
      kategoria: state.kategoria,
      produkt: state.produkt,
      ilosc: state.ilosc,
      cena: state.cena,
      miara: state.miara,
      miaraUnit: state.miaraUnit,
      iloscWOpakowaniu: state.iloscWOpakowaniu,
      kosztDostawy: state.kosztDostawy,
      zwrot: state.zwrot,
      link: state.link,
      komentarz: state.komentarz,
      toBeSent: !isUpdating,
      toBeUpdated: isUpdating,
    );

    var box = await Hive.openBox<ExpensesListElementModel>(AuthService().getBoxName());
    await box.put(newExpense.localId, newExpense);

    await loadOrRefreshLocalData();

    navigatorKey.currentState?.pop();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(expense == null ? 'Wydatek dodany pomyślnie' : 'Wydatek zaktualizowany pomyślnie')));
  }
}

void updateExpansionTileKeys(List<Key> expansionTileKeys, List<ExpensesListElementModel> filteredData) {
  expansionTileKeys.clear();
  for (int i = 0; i < filteredData.length; i++) {
    expansionTileKeys.add(GlobalKey());
  }
}

void initExpansionTileKeys(Function setState, List<Key> expansionTileKeys, List<ExpensesListElementModel> filteredData) {
  updateExpansionTileKeys(expansionTileKeys, filteredData);
  setState(() {});
}