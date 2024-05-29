import 'package:flutter/material.dart';

enum SortOption { date, product, cost }

class FilterDataPage extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?, String?, String?, SortOption, bool) onFiltersApplied;
  final DateTime? currentStartDate;
  final DateTime? currentEndDate;
  final String? currentProductFilter;
  final String? currentShopFilter;
  final String? currentCategoryFilter;
  final String? currentFilterOption;
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
    this.currentFilterOption,
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

    selectedFilterOption = widget.currentFilterOption ?? 'Opcje filtrowania';
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
      selectedFilterOption = 'Opcje filtrowania';
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
            sortOptionsWidget(),
            const SizedBox(height: 16),
            filterOptionsWidget(),
            textFormFieldsWidget(),
            const SizedBox(height: 16),
            buttonsWidget(),
          ],
        ),
      ),
    );
  }

  Widget sortOptionsWidget() {
    return Row(
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
          icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () {
            setState(() {
              isAscending = !isAscending;
            });
          },
        ),
      ],
    );
  }

  Widget filterOptionsWidget() {
    return ListTile(
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
                    DateTime today = DateTime.now();
                    selectedFilterOption = 'Dzisiaj';
                    _setDateRange(today, today, 'Dzisiaj');
                  },
                ),
                ListTile(
                  title: const Text('Obecny tydzień'),
                  onTap: () {
                    Navigator.pop(context);
                    DateTime now = DateTime.now();
                    DateTime startOfWeek =
                        now.subtract(Duration(days: now.weekday - 1));
                    selectedFilterOption = 'Obecny tydzień';
                    _setDateRange(
                        startOfWeek,
                        startOfWeek.add(const Duration(days: 6)),
                        'Obecny tydzień');
                  },
                ),
                ListTile(
                  title: const Text('Obecny miesiąc'),
                  onTap: () {
                    Navigator.pop(context);
                    DateTime now = DateTime.now();
                    selectedFilterOption = 'Obecny miesiąc';
                    _setDateRange(
                      DateTime(now.year, now.month, 1),
                      DateTime(now.year, now.month + 1, 0),
                      'Obecny miesiąc',
                    );
                  },
                ),
                ListTile(
                  title: const Text('7 dni wstecz'),
                  onTap: () {
                    Navigator.pop(context);
                    DateTime now = DateTime.now();
                    selectedFilterOption = '7 dni wstecz';
                    _setDateRange(
                      now.subtract(const Duration(days: 7)),
                      now,
                      '7 dni wstecz',
                    );
                  },
                ),
                ListTile(
                  title: const Text('30 dni wstecz'),
                  onTap: () {
                    Navigator.pop(context);
                    DateTime now = DateTime.now();
                    selectedFilterOption = '30 dni wstecz';
                    _setDateRange(
                      now.subtract(const Duration(days: 30)),
                      now,
                      '30 dni wstecz',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Obecny rok'),
                  onTap: () {
                    Navigator.pop(context);
                    DateTime now = DateTime.now();
                    selectedFilterOption = 'Obecny rok';
                    _setDateRange(
                      DateTime(now.year, 1, 1),
                      DateTime(now.year + 1, 1, 0),
                      'Obecny rok',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Rok wstecz'),
                  onTap: () {
                    Navigator.pop(context);
                    DateTime now = DateTime.now();
                    selectedFilterOption = 'Rok wstecz';
                    _setDateRange(
                      DateTime(now.year - 1, 1, 1),
                      DateTime(now.year, 1, 0),
                      'Rok wstecz',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Całość'),
                  onTap: () {
                    Navigator.pop(context);
                    selectedFilterOption = 'Całość';
                    _setDateRange(null, null, 'Całość'); // No date range
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget textFormFieldsWidget() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Produkt'),
          onChanged: (value) {
            setState(() {
              productFilter = value;
            });
          },
          initialValue: productFilter,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Sklep'),
          onChanged: (value) {
            setState(() {
              shopFilter = value;
            });
          },
          initialValue: shopFilter,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Kategoria'),
          onChanged: (value) {
            setState(() {
              categoryFilter = value;
            });
          },
          initialValue: categoryFilter,
        ),
      ],
    );
  }

  Widget buttonsWidget() {
    return Row(
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
    );
  }
}
