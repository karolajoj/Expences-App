import '../../Repositories/Local Data/expenses_list_element.dart';
import 'filter_date_options_list.dart';
import 'filters_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Utils/utils.dart';

enum SortOption { date, shop, category, product, cost }

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}

bool isSameRange(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
  return isSameDay(start1, start2) && isSameDay(end1, end2);
}

void applyFilters(
  DateTime? startDate,
  DateTime? endDate,
  String? productFilter,
  String? shopFilter,
  String? categoryFilter,
  SortOption? orderBy,
  bool? isAscending,
  List<ExpensesListElementModel> csvData,
  List<ExpensesListElementModel> filteredData,
) {
  filteredData.clear();
  
  if (csvData.isNotEmpty) {
    filteredData.addAll(csvData.where((element) {
      bool withinDateRange = true;
      bool matchesProductFilter = true;
      bool matchesShopFilter = true;
      bool matchesCategoryFilter = true;

      if (startDate != null && endDate != null) {
        withinDateRange = (element.data.isAfter(startDate) || element.data.isAtSameMomentAs(startDate))
                       && (element.data.isBefore(endDate) || element.data.isAtSameMomentAs(endDate));
      }

      if (productFilter != null) {
        matchesProductFilter = element.produkt.toLowerCase().contains(productFilter.toLowerCase());
      }

      if (shopFilter != null) {
        matchesShopFilter = element.sklep.toLowerCase().contains(shopFilter.toLowerCase());
      }

      if (categoryFilter != null) {
        matchesCategoryFilter = element.kategoria.toLowerCase().contains(categoryFilter.toLowerCase());
      }

      return withinDateRange && matchesProductFilter && matchesShopFilter && matchesCategoryFilter;
    }).toList());

    List<SortOption> sortOrder;
    switch (orderBy) {
      case SortOption.date:
        sortOrder = [SortOption.date, SortOption.shop, SortOption.category, SortOption.product];
        break;
      case SortOption.product:
        sortOrder = [SortOption.product, SortOption.shop, SortOption.category, SortOption.date];
        break;
      case SortOption.cost:
        sortOrder = [SortOption.cost, SortOption.date, SortOption.shop, SortOption.category, SortOption.product];
        break;
      default:
        sortOrder = [SortOption.date, SortOption.shop, SortOption.category, SortOption.product];
        break;
    }

    filteredData.sort((a, b) {
      for (var option in sortOrder) {
        int comparison;
        switch (option) {
          case SortOption.date:
            comparison = a.data.compareTo(b.data);
            break;
          case SortOption.shop:
            comparison = a.sklep.compareTo(b.sklep);
            break;
          case SortOption.category:
            comparison = a.kategoria.compareTo(b.kategoria);
            break;
          case SortOption.product:
            comparison = a.produkt.compareTo(b.produkt);
            break;
          case SortOption.cost:
            comparison = a.totalCost.compareTo(b.totalCost);
            break;
          default:
            comparison = 0;
            break;
        }
        if (comparison != 0) {
          return comparison;
        }
      }
      return 0;
    });

    if (isAscending != null && !isAscending) {
      filteredData = filteredData.reversed.toList();
    }
  }
}

void applyDefaultFilters(
  Function setState,
  List<ExpensesListElementModel> csvData,
  List<ExpensesListElementModel> filteredData,
) {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  applyFilters(startDate, endDate, null, null, null, SortOption.date, true, csvData, filteredData);
  setState(() {});
}

void openFilterDialog(
  BuildContext context,
  Function(DateTime?, DateTime?, String?, String?, String?, SortOption, bool) onFiltersApplied,
  DateTime? currentStartDate,
  DateTime? currentEndDate,
  String? currentProductFilter,
  String? currentShopFilter,
  String? currentCategoryFilter,
  SortOption currentSortOption,
  bool isAscending
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FilterDataPage(
        onFiltersApplied: onFiltersApplied,
        currentStartDate: currentStartDate,
        currentEndDate: currentEndDate,
        currentProductFilter: currentProductFilter,
        currentShopFilter: currentShopFilter,
        currentCategoryFilter: currentCategoryFilter,
        currentSortOption: currentSortOption,
        isAscending: isAscending,
      );
    },
  );
}

void updateFilterValues(
  Function setState,
  DateTime? startDate,
  DateTime? endDate,
  String? productFilter,
  String? shopFilter,
  String? categoryFilter,
  SortOption sortOption,
  bool isAscending,
  void Function(DateTime?) setCurrentStartDate,
  void Function(DateTime?) setCurrentEndDate,
  void Function(String?) setCurrentProductFilter,
  void Function(String?) setCurrentShopFilter,
  void Function(String?) setCurrentCategoryFilter,
  void Function(SortOption) setCurrentSortOption,
  void Function(bool) setCurrentIsAscending,
) {
  setState(() {
    setCurrentStartDate(startDate);
    setCurrentEndDate(endDate);
    setCurrentProductFilter(productFilter);
    setCurrentShopFilter(shopFilter);
    setCurrentCategoryFilter(categoryFilter);
    setCurrentSortOption(sortOption);
    setCurrentIsAscending(isAscending);
  });
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
  } else if (isSameRange(start, end, now.subtract(const Duration(days: 365)), now)) {
    return 'Rok wstecz';
  } else {
    DateFormat dateFormat = DateFormat('dd.MM.yyyy');
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }
}

Future<void> loadSuggestions(Function setState) async {
  await loadAllSuggestions();
  setState(() {});
}

void onSortOptionChanged(Function setState, SortOption option, void Function(SortOption) updateSortOption) {
  setState(() {
    updateSortOption(option);
  });
}

void onOrderChanged(Function setState, bool ascending, void Function(bool) updateOrder) {
  setState(() {
    updateOrder(ascending);
  });
}

void showFilterOptions(
  BuildContext context,
  Function(DateTime?, DateTime?, String) onSelectDateRange,
  DateTime now,
  List<DateTime?> selectedDates,
) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return FilterOptionsList(
        onSelectDateRange: onSelectDateRange,
        now: now,
        selectedDates: selectedDates,
      );
    },
  );
}

void setDateRange(Function setState, DateTime? start, DateTime? end, String filterName, void Function(DateTime?) updateStartDate, void Function(DateTime?) updateEndDate, void Function(String) updateSelectedFilterOption) {
  setState(() {
    updateStartDate(start);
    updateEndDate(end);
    updateSelectedFilterOption(filterName);
  });
}

void clearFilters(
  Function setState,
  ValueNotifier<String> productNotifier,
  ValueNotifier<String> shopNotifier,
  ValueNotifier<String> categoryNotifier,
  void Function(DateTime?) updateStartDate,
  void Function(DateTime?) updateEndDate,
  void Function(String?) updateProductFilter,
  void Function(String?) updateShopFilter,
  void Function(String?) updateCategoryFilter,
  void Function(SortOption) updateSortOption,
  void Function(bool) updateOrder,
  void Function(String) updateSelectedFilterOption,
) {
  setState(() {
    updateStartDate(null);
    updateEndDate(null);
    updateProductFilter(null);
    updateShopFilter(null);
    updateCategoryFilter(null);
    updateSortOption(SortOption.date);
    updateOrder(true);
    updateSelectedFilterOption('Całość');
    productNotifier.value = '';
    shopNotifier.value = '';
    categoryNotifier.value = '';
  });
}

void applyFiltersAndClose(
  BuildContext context,
  DateTime? startDate,
  DateTime? endDate,
  ValueNotifier<String> productNotifier,
  ValueNotifier<String> shopNotifier,
  ValueNotifier<String> categoryNotifier,
  SortOption sortOption,
  bool isAscending,
  Function(DateTime?, DateTime?, String?, String?, String?, SortOption, bool) onFiltersApplied,
) {
  onFiltersApplied(
    startDate,
    endDate,
    productNotifier.value.isNotEmpty ? productNotifier.value : null,
    shopNotifier.value.isNotEmpty ? shopNotifier.value : null,
    categoryNotifier.value.isNotEmpty ? categoryNotifier.value : null,
    sortOption,
    isAscending,
  );
  Navigator.of(context).pop();
}