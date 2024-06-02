import 'package:flutter/material.dart';

enum SortOption { date, product, cost }

class FilterDataPage extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?, String?, String?, SortOption, bool) onFiltersApplied;
  final DateTime? currentStartDate;
  final DateTime? currentEndDate;
  final String? currentProductFilter;
  final String? currentShopFilter;
  final String? currentCategoryFilter;
  final SortOption currentSortOption;
  final bool isAscending;

  const FilterDataPage({
    super.key,
    required this.onFiltersApplied,
    this.currentStartDate,
    this.currentEndDate,
    this.currentProductFilter,
    this.currentShopFilter,
    this.currentCategoryFilter,
    this.currentSortOption = SortOption.date,
    this.isAscending = true,
  });

  @override
  FilterDataPageState createState() => FilterDataPageState();
}

class FilterDataPageState extends State<FilterDataPage> {
  late DateTime? startDate;
  late DateTime? endDate;
  late String? productFilter;
  late String? shopFilter;
  late String? categoryFilter;
  late String selectedFilterOption;
  late SortOption sortOption;
  late bool isAscending;

  late TextEditingController productController;
  late TextEditingController shopController;
  late TextEditingController categoryController;
  
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    startDate = widget.currentStartDate;
    endDate = widget.currentEndDate;
    productFilter = widget.currentProductFilter;
    shopFilter = widget.currentShopFilter;
    categoryFilter = widget.currentCategoryFilter;
    sortOption = widget.currentSortOption;
    isAscending = widget.isAscending;

    productController = TextEditingController(text: productFilter);
    shopController = TextEditingController(text: shopFilter);
    categoryController = TextEditingController(text: categoryFilter);

    if (widget.currentStartDate != null && widget.currentEndDate != null) {
      selectedFilterOption = _getFilterOptionByDateRange(widget.currentStartDate!, widget.currentEndDate!);
    } else {
      selectedFilterOption = 'Całość';
    }
  }

 String _getFilterOptionByDateRange(DateTime start, DateTime end) {
    DateTime now = DateTime.now();
    if (_isSameDay(start, now) && _isSameDay(end, now)) {
      return 'Dzisiaj';
    } else if (_isSameRange(start, end, now.subtract(Duration(days: now.weekday - 1)), now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: 6)))) {
      return 'Obecny tydzień';
    } else if (_isSameRange(start, end, DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0))) {
      return 'Obecny miesiąc';
    } else if (_isSameRange(start, end, now.subtract(const Duration(days: 7)), now)) {
      return '7 dni wstecz';
    } else if (_isSameRange(start, end, now.subtract(const Duration(days: 30)), now)) {
      return '30 dni wstecz';
    } else if (_isSameRange(start, end, DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 0))) {
      return 'Obecny rok';
    } else if (_isSameRange(start, end, DateTime(now.year - 1, 1, 1), DateTime(now.year, 1, 0))) {
      return 'Rok wstecz';
    } else {
      return 'Całość';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool _isSameRange(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return _isSameDay(start1, start2) && _isSameDay(end1, end2);
  }

  @override
  void dispose() {
    productController.dispose();
    shopController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  void _setDateRange(DateTime? start, DateTime? end, String filterName) {
    setState(() {
      startDate = start;
      endDate = end;
      selectedFilterOption = filterName;
    });
  }

  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
      productFilter = null;
      shopFilter = null;
      categoryFilter = null;
      sortOption = SortOption.date;
      isAscending = true;
      selectedFilterOption = 'Całość';
      productController.clear();
      shopController.clear();
      categoryController.clear();
    });
  }

  void _applyFiltersAndClose() {
    widget.onFiltersApplied(
      startDate,
      endDate,
      productFilter,
      shopFilter,
      categoryFilter,
      sortOption,
      isAscending,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtruj dane'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sortuj'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('Data'),
                  selected: sortOption == SortOption.date,
                  onSelected: (selected) {
                    setState(() {
                      sortOption = SortOption.date;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Produkt'),
                  selected: sortOption == SortOption.product,
                  onSelected: (selected) {
                    setState(() {
                      sortOption = SortOption.product;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Koszt'),
                  selected: sortOption == SortOption.cost,
                  onSelected: (selected) {
                    setState(() {
                      sortOption = SortOption.cost;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                      isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Opcje filtrowania'),
            ListTile(
              title: Text(selectedFilterOption),
              trailing: const Icon(Icons.expand_more),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Dzisiaj'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(now, now, 'Dzisiaj');
                          },
                        ),
                        ListTile(
                          title: const Text('Obecny tydzień'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                            _setDateRange(startOfWeek,startOfWeek.add(const Duration(days: 6)),'Obecny tydzień');
                          },
                        ),
                        ListTile(
                          title: const Text('Obecny miesiąc'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(DateTime(now.year, now.month, 1),DateTime(now.year, now.month + 1, 0),'Obecny miesiąc');
                          },
                        ),
                        ListTile(
                          title: const Text('7 dni wstecz'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(now.subtract(const Duration(days: 7)),now, '7 dni wstecz');
                          },
                        ),
                        ListTile(
                          title: const Text('30 dni wstecz'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(now.subtract(const Duration(days: 30)),now,'30 dni wstecz');
                          },
                        ),
                        ListTile(
                          title: const Text('Obecny rok'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(DateTime(now.year, 1, 1),DateTime(now.year + 1, 1, 0), 'Obecny rok');
                          },
                        ),
                        ListTile(
                          title: const Text('Rok wstecz'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(DateTime(now.year - 1, 1, 1),DateTime(now.year, 1, 0), 'Rok wstecz');
                          },
                        ),
                        ListTile(
                          title: const Text('Całość'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(null, null, "Całość"); // No date range
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            TextFormField(
              controller: productController,
              decoration: const InputDecoration(labelText: 'Produkt'),
              onChanged: (value) {
                setState(() {
                  productFilter = value;
                });
              },
            ),
            TextFormField(
              controller: shopController,
              decoration: const InputDecoration(labelText: 'Sklep'),
              onChanged: (value) {
                setState(() {
                  shopFilter = value;
                });
              },
            ),
            TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Kategoria'),
              onChanged: (value) {
                setState(() {
                  categoryFilter = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: const Text('Czyść filtry'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _applyFiltersAndClose();
                  },
                  child: const Text('Filtruj'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
