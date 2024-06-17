import 'package:flutter/material.dart';
import '../autocomplete_field.dart';
import 'filter_options_list.dart';
import 'choice_chip_row.dart';
import '../utils.dart';

enum SortOption { date, product, cost }


// TODO : Traktować elementy z flagą toBeDeleted jako nieistniejące i ich nie pokazywać w aplikacji
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

  // Potrzebne do popranego czyszczenie pól tekstowych
  late ValueNotifier<String> productNotifier;
  late ValueNotifier<String> shopNotifier;
  late ValueNotifier<String> categoryNotifier;

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

    productNotifier = ValueNotifier(productFilter ?? '');
    shopNotifier = ValueNotifier(shopFilter ?? '');
    categoryNotifier = ValueNotifier(categoryFilter ?? '');

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
      productNotifier.value = '';
      shopNotifier.value = '';
      categoryNotifier.value = '';
    });
  }

  void _applyFiltersAndClose() {
    widget.onFiltersApplied(
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
              valueNotifier: shopNotifier,
              onSelected: (selection) {
                setState(() {
                  shopNotifier.value = selection;
                  shopFilter = selection;
                });
              },
              onClear: () {
                setState(() {
                  shopNotifier.value = '';
                  shopFilter = null;
                });
              },
            ),
            AutocompleteField(
              options: getAllKategorie(),
              label: 'Kategoria',
              valueNotifier: categoryNotifier,
              onSelected: (selection) {
                setState(() {
                  categoryNotifier.value = selection;
                  categoryFilter = selection;
                });
              },
              onClear: () {
                setState(() {
                  categoryNotifier.value = '';
                  categoryFilter = null;
                });
              },
            ),
            AutocompleteField(
              options: getAllProdukty(),
              label: 'Produkt',
              valueNotifier: productNotifier,
              onSelected: (selection) {
                setState(() {
                  productNotifier.value = selection;
                  productFilter = selection;
                });
              },
              onClear: () {
                setState(() {
                  productNotifier.value = '';
                  productFilter = null;
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