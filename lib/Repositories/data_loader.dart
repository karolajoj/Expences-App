import '../../Repositories/Local Data/expenses_list_element.dart';
import 'package:flutter/material.dart';
import '../Filters/filter_utils.dart';
import 'package:hive/hive.dart';
import '../Utils/utils.dart';

Future<void> loadOrRefreshLocalData(
  Function setState,
  List<ExpensesListElementModel> csvData,
  List<ExpensesListElementModel> filteredData,
  Map<String, Color> dateColorMap,
  DateTime? startDate,
  DateTime? endDate,
  String? productFilter,
  String? shopFilter,
  String? categoryFilter,
  SortOption sortOption,
  bool isAscending,
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
) async {
  var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
  List<ExpensesListElementModel> localData = box.values.toList();

  setState(() {
    csvData.clear();
    csvData.addAll(localData.where((expense) => !expense.toBeDeleted).toList());
    filteredData.clear();
    dateColorMap.clear();

    applyFilters(startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending, csvData, filteredData);
    updateDateColorMap(filteredData, dateColorMap);
  });

  // TODO: Zmienić żeby nie zawsze sie to pokazywało
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Załadowano ${filteredData.length} wydatków'), duration: const Duration(milliseconds: 400)));
}