import '../Repositories/Local Data/expenses_list_element.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

void updateDateColorMap(List<ExpensesListElementModel> csvData, Map<String, Color> dateColorMap) {
  for (var row in csvData) {
    String currentDay = DateFormat('dd.MM.yyyy').format(row.data);
    if (!dateColorMap.containsKey(currentDay)) {
      Color newColor = dateColorMap.isEmpty || dateColorMap.values.last == Colors.grey[350]
          ? Colors.blue[100]!
          : Colors.grey[350]!;
      dateColorMap[currentDay] = newColor;
    }
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

List<String> _allSklepy = [];
List<String> _allKategorie = [];
List<String> _allProdukty = [];

Future<void> loadAllSuggestions() async {
  var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
  var allExpenses = box.values.toList();
  _allSklepy = allExpenses.map((expense) => expense.sklep.trim()).where((sklep) => sklep.isNotEmpty).toSet().toList()..sort();
  _allKategorie = allExpenses.map((expense) => expense.kategoria.trim()).where((kategoria) => kategoria.isNotEmpty).toSet().toList()..sort();
  _allProdukty = allExpenses.map((expense) => expense.produkt.trim()).where((produkt) => produkt.isNotEmpty).toSet().toList()..sort();
}

List<String> getAllSklepy() => _allSklepy;
List<String> getAllKategorie() => _allKategorie;
List<String> getAllProdukty() => _allProdukty;
