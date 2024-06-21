import '../Repositories/Local Data/expenses_list_element.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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