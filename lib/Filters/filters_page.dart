import 'package:flutter/material.dart';
import 'filter_sort_options.dart';
import '../Utils/autocomplete_field.dart';
import '../Utils/utils.dart';
import 'filter_utils.dart';


class FiltersPage extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?, String?, String?, SortOption, bool, GlobalKey<ScaffoldMessengerState>) onFiltersApplied;
  final DateTime? currentStartDate;
  final DateTime? currentEndDate;
  final String? currentProductFilter;
  final String? currentShopFilter;
  final String? currentCategoryFilter;
  final SortOption currentSortOption;
  final bool isAscending;
  final GlobalKey<ScaffoldMessengerState> navigatorKey;
  const FiltersPage({
    super.key,
    required this.onFiltersApplied,
    this.currentStartDate,
    this.currentEndDate,
    this.currentProductFilter,
    this.currentShopFilter,
    this.currentCategoryFilter,
    this.currentSortOption = SortOption.date,
    this.isAscending = true,
    required this.navigatorKey,
  });

  @override
  FiltersPageState createState() => FiltersPageState();
}

class FiltersPageState extends State<FiltersPage> {
  late DateTime? startDate;
  late DateTime? endDate;
  late String? productFilter;
  late String? shopFilter;
  late String? categoryFilter;
  late String selectedFilterOption;
  late SortOption sortOption;
  late bool isAscending;

  // Potrzebne do poprawnego czyszczenia pól tekstowych
  late ValueNotifier<String> productNotifier;
  late ValueNotifier<String> shopNotifier;
  late ValueNotifier<String> categoryNotifier;

  DateTime now = DateTime.now();

  final List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    loadSuggestions(setState);
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
            FilterSortOptions(
              sortOption: sortOption,
              isAscending: isAscending,
              onSortOptionChanged: (option) => onSortOptionChanged(setState, option, (value) => sortOption = value),
              onOrderChanged: (ascending) => onOrderChanged(setState, ascending, (value) => isAscending = value),
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
                showFilterOptions(context, (start, end, filterName) => setDateRange(setState, start, end, filterName, (value) => startDate = value, (value) => endDate = value, (value) => selectedFilterOption = value), now, _selectedDates);
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
                  onPressed: () => clearFilters(setState, productNotifier, shopNotifier, categoryNotifier, (value) => startDate = value, (value) => endDate = value, (value) => productFilter = value, (value) => shopFilter = value, (value) => categoryFilter = value, (value) => sortOption = value, (value) => isAscending = value, (value) => selectedFilterOption = value),
                  child: const Text('Czyść filtry'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => applyFiltersAndClose(context, startDate, endDate, productNotifier, shopNotifier, categoryNotifier, sortOption, isAscending, widget.onFiltersApplied, widget.navigatorKey),
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