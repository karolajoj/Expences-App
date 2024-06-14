import 'package:flutter/material.dart';
import '../autocomplete_field.dart';
import 'filter_options_list.dart';
import 'choice_chip_row.dart';
import '../utils.dart';

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

  final List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    startDate = widget.currentStartDate;
    endDate = widget.currentEndDate;
    productFilter = widget.currentProductFilter;
    shopFilter = widget.currentShopFilter;
    categoryFilter = widget.currentCategoryFilter;
    sortOption = widget.currentSortOption;
    isAscending = widget.isAscending;

    productController = TextEditingController(text: productFilter ?? '');
    shopController = TextEditingController(text: shopFilter ?? '');
    categoryController = TextEditingController(text: categoryFilter ?? '');

    if (widget.currentStartDate != null && widget.currentEndDate != null) {
      selectedFilterOption = getFilterOptionByDateRange(widget.currentStartDate!, widget.currentEndDate!, now);
    } else {
      selectedFilterOption = 'Całość';
    }
  }

  Future<void> _loadSuggestions() async {
    await loadAllSuggestions();
    setState(() {});
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
      productController.text.isNotEmpty ? productController.text : null,
      shopController.text.isNotEmpty ? shopController.text : null,
      categoryController.text.isNotEmpty ? categoryController.text : null,
      sortOption,
      isAscending,
    );
    Navigator.of(context).pop();
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FilterOptionsList(
          onSelectDateRange: _setDateRange,
          now: now,
          selectedDates: _selectedDates,
        );
      },
    );
  }

  void _onSortOptionChanged(SortOption option) {
    setState(() {
      sortOption = option;
    });
  }

  void _onOrderChanged(bool ascending) {
    setState(() {
      isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtruj dane'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Sortuj'),
            ChoiceChipRow(
              sortOption: sortOption,
              isAscending: isAscending,
              onSortOptionChanged: _onSortOptionChanged,
              onOrderChanged: _onOrderChanged,
            ),
            const SizedBox(height: 16),
            const Text('Opcje filtrowania'),
            ListTile(
              title: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(selectedFilterOption)
                ],
              ),
              trailing: const Icon(Icons.expand_more),
              onTap: () {
                _showFilterOptions(context);
              },
            ),
            AutocompleteField(
              options: getAllSklepy(),
              label: 'Sklep',
              controller: shopController,
              onSelected: (selection) {
                setState(() {
                  shopController.text = selection;
                  shopFilter = selection;
                });
              },
            ),
            AutocompleteField(
              options: getAllKategorie(),
              label: 'Kategoria',
              controller: categoryController,
              onSelected: (selection) {
                setState(() {
                  categoryController.text = selection;
                  categoryFilter = selection;
                });
              },
            ),
            AutocompleteField(
              options: getAllProdukty(),
              label: 'Produkt',
              controller: productController,
              onSelected: (selection) {
                setState(() {
                  productController.text = selection;
                  productFilter = selection;
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
                  onPressed: _applyFiltersAndClose,
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