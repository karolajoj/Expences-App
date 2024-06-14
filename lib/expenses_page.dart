import 'Repositories/Import & Export/csv_import_export.dart';
import 'package:expenses_app_project/add_expense_page.dart';
import 'Repositories/Local Data/expenses_list_element.dart';
import 'Repositories/Local Data/expenses_provider.dart';
import 'package:expenses_app_project/drawer.dart';
import 'Repositories/Online Data/firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'Filters/filter_data_page.dart';
import 'expense_tile.dart';
import 'utils.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  ExpensesPageState createState() => ExpensesPageState();
}

class ExpensesPageState extends State<ExpensesPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  List<ExpensesListElementModel> filteredData = [];
  List<ExpensesListElementModel> csvData = [];
  Map<String, Color> dateColorMap = {};
  List<Key> expansionTileKeys = [];
  Set<int> expandedTiles = {};

  FirestoreService firestore = FirestoreService();
  ExpensesProvider expensesProvider = ExpensesProvider(Hive.box<ExpensesListElementModel>('expenses_local'));

  // Pola do przechowywania aktualnych filtrów
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;
  String? _currentProductFilter;
  String? _currentShopFilter;
  String? _currentCategoryFilter;
  SortOption _currentSortOption = SortOption.date;
  bool _isAscending = true;

  ExpensesListElementModel newExpense = ExpensesListElementModel(
    id: '',
    data: DateTime.now(),
    sklep: 'Supermarket',
    kategoria: 'Żywność',
    produkt: 'Mleko',
    ilosc: 2,
    cena: 4.99,
    miara: 1000,
    miaraUnit: 'ml',
    iloscWOpakowaniu: 1,
    kosztDostawy: 5.0,
    zwrot: false,
    link: 'https://example.com',
    komentarz: 'Zakup na tydzień',
  );

  @override
  void initState() {
    super.initState();
    _initExpansionTileKeys();
    loadOrRefreshLocalData();
  }

  Future<void> loadOrRefreshLocalData() async {
    var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
    List<ExpensesListElementModel> localData = box.values.toList();

    setState(() {
      csvData.clear();
      csvData.addAll(localData);
      filteredData.clear();
      filteredData.addAll(localData);
      dateColorMap.clear();

      updateDateColorMap(csvData, dateColorMap);
      _applyDefaultFilters();
    });

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('Załadowano ${localData.length} wydatków')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: _buildAppBar(context),
        drawer: AppDrawer(
          onLoadCSV: (context) => loadCSV(setState, csvData, filteredData, dateColorMap, _applyDefaultFilters, _scaffoldMessengerKey, true),
          onReplaceCSV: (context) => loadCSV(setState, csvData, filteredData, dateColorMap, _applyDefaultFilters, _scaffoldMessengerKey, false),
          onExportAllData: (context) => exportCSV(context, _scaffoldMessengerKey, csvData),
          onExportFilteredData: (context) => exportCSV(context, _scaffoldMessengerKey, filteredData),
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _addNewExpense(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _addNewExpense(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpensePage(expense: null),
      ),
    ).then((_) async {
      await firestore.addExpense(newExpense: newExpense, context: context, scaffoldMessengerKey: _scaffoldMessengerKey);
      await expensesProvider.addExpense(newExpense);
      await loadOrRefreshLocalData();
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Lista wydatków'),
      actions: [
        IconButton(
          onPressed: () => _openFilterDialog(context),
          icon: const Icon(Icons.tune),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Center(
      child: csvData.isEmpty ? const Text('Brak danych CSV') : _buildListView(),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (BuildContext context, int index) {
              final row = filteredData[index];
              return ExpenseTile(
                row: row,
                index: index,
                dateColorMap: dateColorMap,
                expandedTiles: expandedTiles,
                scaffoldMessengerKey: _scaffoldMessengerKey,
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (expanded) {
                      expandedTiles.add(index);
                    } else {
                      expandedTiles.remove(index);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _applyDefaultFilters() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();
    _applyFilters(startDate, endDate, null, null, null, SortOption.date, true);
  }

  void _openFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDataPage(
          onFiltersApplied: (startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending) {
            _applyFilters(startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending);
            _updateFilterValues(startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending);
          },
          currentStartDate: _currentStartDate,
          currentEndDate: _currentEndDate,
          currentProductFilter: _currentProductFilter,
          currentShopFilter: _currentShopFilter,
          currentCategoryFilter: _currentCategoryFilter,
          currentSortOption: _currentSortOption,
          isAscending: _isAscending,
        );
      },
    );
  }

  void _updateFilterValues(
    DateTime? startDate, DateTime? endDate, String? productFilter, String? shopFilter, String? categoryFilter, SortOption sortOption, bool isAscending) {
    setState(() {
      _currentStartDate = startDate;
      _currentEndDate = endDate;
      _currentProductFilter = productFilter;
      _currentShopFilter = shopFilter;
      _currentCategoryFilter = categoryFilter;
      _currentSortOption = sortOption;
      _isAscending = isAscending;
    });
  }

  void _applyFilters(DateTime? startDate, DateTime? endDate, String? productFilter, String? shopFilter, String? categoryFilter, SortOption? orderBy, bool? isAscending) {
    if (csvData.isNotEmpty) {
      setState(() {
        filteredData = csvData.where((element) {
          bool withinDateRange = true;
          bool matchesProductFilter = true;
          bool matchesShopFilter = true;
          bool matchesCategoryFilter = true;

          if (startDate != null && endDate != null) {
            withinDateRange = element.data.isAfter(startDate) && element.data.isBefore(endDate);
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
        }).toList();

        switch (orderBy) {
          case SortOption.date:
            filteredData.sort((a, b) => a.data.compareTo(b.data));
            break;
          case SortOption.product:
            filteredData.sort((a, b) => a.produkt.compareTo(b.produkt));
            break;
          case SortOption.cost:
            filteredData.sort((a, b) => a.totalCost.compareTo(b.totalCost));
            break;
          default:
            break;
        }

        if (isAscending != null && !isAscending) {
          filteredData = filteredData.reversed.toList();
        }

        _updateExpansionTileKeys();
      });
    }
  }

  void _initExpansionTileKeys() {
    expansionTileKeys.clear();
    for (int i = 0; i < filteredData.length; i++) {
      expansionTileKeys.add(GlobalKey());
    }
  }

  void _updateExpansionTileKeys() {
    setState(() {
      _initExpansionTileKeys();
    });
  }
}