import 'package:expenses_app_project/Main%20Pages/Expenses%20List/expense_menu.dart';
import '../../Repositories/Import & Export & Delete/data_delete.dart';
import '../../Repositories/Import & Export & Delete/data_export.dart';
import '../../Repositories/Import & Export & Delete/data_import.dart';
import '../../Repositories/Local Data/expenses_list_element.dart';
import '../../Repositories/Local Data/expenses_provider.dart';
import '../../Repositories/Online Data/firestore.dart';
import 'package:expenses_app_project/main.dart';
import '../../Repositories/data_loader.dart';
import 'package:flutter/material.dart';
import '../../Filters/filter_utils.dart';
import 'package:hive/hive.dart';
import 'add_expense_page.dart';
import 'expense_tile.dart';
import 'expense_utils.dart';

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

  DateTime? _currentStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime? _currentEndDate = DateTime.now();
  String? _currentProductFilter;
  String? _currentShopFilter;
  String? _currentCategoryFilter;
  SortOption _currentSortOption = SortOption.date;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    initExpansionTileKeys(setState, expansionTileKeys, filteredData);
    loadOrRefreshLocalData(setState, csvData, filteredData, dateColorMap, _currentStartDate, _currentEndDate, _currentProductFilter, _currentShopFilter, _currentCategoryFilter, _currentSortOption, _isAscending, _scaffoldMessengerKey);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: _buildAppBar(context),
        drawer: ExpenseMenu(
          onLoadCSV: (context) => loadCSV(setState, csvData, filteredData, dateColorMap, () => applyDefaultFilters(setState, csvData, filteredData), _scaffoldMessengerKey, true),
          onReplaceCSV: (context) => loadCSV(setState, csvData, filteredData, dateColorMap, () => applyDefaultFilters(setState, csvData, filteredData), _scaffoldMessengerKey, false),
          onExportAllData: (context) => exportCSV(context, _scaffoldMessengerKey, csvData),
          onExportFilteredData: (context) => exportCSV(context, _scaffoldMessengerKey, filteredData),
          onDeleteAllData: (context) => markAllDataForDeletion(context, _scaffoldMessengerKey, () => loadOrRefreshLocalData(setState, csvData, filteredData, dateColorMap, _currentStartDate, _currentEndDate, _currentProductFilter, _currentShopFilter, _currentCategoryFilter, _currentSortOption, _isAscending, _scaffoldMessengerKey), expensesProvider, navigatorKey),
          onDeleteFilteredData: (context) => markFilteredDataForDeletion(context, filteredData, _scaffoldMessengerKey, () => loadOrRefreshLocalData(setState, csvData, filteredData, dateColorMap, _currentStartDate, _currentEndDate, _currentProductFilter, _currentShopFilter, _currentCategoryFilter, _currentSortOption, _isAscending, _scaffoldMessengerKey), expensesProvider, navigatorKey),
          navigatorKey: navigatorKey,
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddExpensePage(
                    expense: null,
                    loadOrRefreshLocalData: () => loadOrRefreshLocalData(setState, csvData, filteredData, dateColorMap, _currentStartDate, _currentEndDate, _currentProductFilter, _currentShopFilter, _currentCategoryFilter, _currentSortOption, _isAscending, _scaffoldMessengerKey),
                    navigatorKey: navigatorKey)));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Lista wydatków'),
      actions: [
        IconButton(
          onPressed: () => openFilterDialog(
            context,
            (startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending, scaffoldMessengerKey) {
              applyFilters(startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending, csvData, filteredData);
              updateFilterValues(setState, startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending,
                  (value) => _currentStartDate = value,
                  (value) => _currentEndDate = value,
                  (value) => _currentProductFilter = value,
                  (value) => _currentShopFilter = value,
                  (value) => _currentCategoryFilter = value,
                  (value) => _currentSortOption = value,
                  (value) => _isAscending = value);
              loadOrRefreshLocalData(setState, csvData, filteredData, dateColorMap, startDate, endDate, productFilter, shopFilter, categoryFilter, sortOption, isAscending, scaffoldMessengerKey);
              setState(() {});
            },
            _currentStartDate,
            _currentEndDate,
            _currentProductFilter,
            _currentShopFilter,
            _currentCategoryFilter,
            _currentSortOption,
            _isAscending,
            _scaffoldMessengerKey,
          ),
          icon: const Icon(Icons.tune),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Center(
      child: csvData.isEmpty 
        ? const Text('Brak danych CSV') 
        : RefreshIndicator(
            onRefresh: () => loadOrRefreshLocalData(setState, csvData, filteredData, dateColorMap, _currentStartDate, _currentEndDate, _currentProductFilter, _currentShopFilter, _currentCategoryFilter, _currentSortOption, _isAscending, _scaffoldMessengerKey),
            child: _buildListView(),
          ),
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
                loadOrRefreshLocalData: () => loadOrRefreshLocalData(setState, csvData, filteredData, dateColorMap, _currentStartDate, _currentEndDate, _currentProductFilter, _currentShopFilter, _currentCategoryFilter, _currentSortOption, _isAscending, _scaffoldMessengerKey),
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
}