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

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}

bool isSameRange(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
  return isSameDay(start1, start2) && isSameDay(end1, end2);
}

String getFilterOptionByDateRange(DateTime start, DateTime end, DateTime now) {
  if (isSameDay(start, now) && isSameDay(end, now)) {
    return 'Dzisiaj';
  } else if (isSameRange(start, end, now.subtract(Duration(days: now.weekday - 1)), now.subtract(Duration(days: now.weekday - 1)).add(const Duration(days: 6)))) {
    return 'Obecny tydzień';
  } else if (isSameRange(start, end, DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0))) {
    return 'Obecny miesiąc';
  } else if (isSameRange(start, end, now.subtract(const Duration(days: 7)), now)) {
    return '7 dni wstecz';
  } else if (isSameRange(start, end, now.subtract(const Duration(days: 30)), now)) {
    return '30 dni wstecz';
  } else if (isSameRange(start, end, DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 0))) {
    return 'Obecny rok';
  } else if (isSameRange(start, end, DateTime(now.year - 1, 1, 1), DateTime(now.year, 1, 0))) {
    return 'Rok wstecz';
  } else {
    DateFormat dateFormat = DateFormat('dd.MM.yyyy');
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }
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
