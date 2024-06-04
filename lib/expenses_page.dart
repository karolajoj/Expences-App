import 'package:expenses_app_project/drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'expenses_list_element.dart';
import 'filter_data_page.dart';
import 'package:intl/intl.dart';
import 'csv_import_export.dart';
import 'Firestore/firestore.dart';

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

  // Pola do przechowywania aktualnych filtrów
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;
  String? _currentProductFilter;
  String? _currentShopFilter;
  String? _currentCategoryFilter;
  SortOption _currentSortOption = SortOption.date;
  bool _isAscending = true;

 ExpensesListElementModel newExpense = ExpensesListElementModel(
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
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: _buildAppBar(context),
        drawer: AppDrawer(
          onLoadCSV: (context) => loadCSV(context, setState, csvData, filteredData, dateColorMap, _applyDefaultFilters, _scaffoldMessengerKey),
          onExportAllData: (context) => exportCSV(context, _scaffoldMessengerKey, csvData),
          onExportFilteredData: (context) => exportCSV(context, _scaffoldMessengerKey, filteredData),
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
          await firestore.addNewExpense(newExpense);
        },
            child: const Icon(Icons.add),
          )),
    );
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
              return _buildListTile(row, context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(ExpensesListElementModel row, BuildContext context, int index) {
    String currentDay = DateFormat('dd.MM.yyyy').format(row.data);

    Color rowColor = index.isEven ? dateColorMap[currentDay]! : dateColorMap[currentDay]!.withOpacity(0.6);

    return Container(
      color: rowColor,
      child: ExpansionTile(
        key: expansionTileKeys[index],
        trailing: _buildTrailingText(row),
        title: _buildTitle(currentDay, row, index),
        children: _buildExpansionChildren(row, context),
        onExpansionChanged: (bool expanded) {
          setState(() {
            if (expanded) {
              expandedTiles.add(index);
            } else {
              expandedTiles.remove(index);
            }
          });
        },
      ),
    );
  }

  Widget _buildTrailingText(ExpensesListElementModel row) {
    return Text(
      row.zwrot ? 'Zwrócono' : '${row.totalCost.toStringAsFixed(2)} zł',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildTitle(String currentDay, ExpensesListElementModel row, int index) {
    bool isExpanded = expandedTiles.contains(index);

    return Row(
      children: [
        // Day
        Text(currentDay),
        // Spacer
        Container(width: 1, height: 24, color: Colors.grey, margin: const EdgeInsets.symmetric(horizontal: 8)),
        // Shop
        Expanded(
          child: Text(
            row.produkt,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: isExpanded,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildExpansionChildren(ExpensesListElementModel row, BuildContext context) {
    return [
      Row(
        children: [
          _buildShopInfo(row, context),
          _buildProductDetails(row),
          _buildPriceDetails(row),
          SizedBox(width: 10, child: Container(color: Colors.red)),
        ],
      ),
      if (row.link.isNotEmpty) _buildLinkTile(row, context, _scaffoldMessengerKey),
      if (row.komentarz.isNotEmpty && row.komentarz.trim().isNotEmpty)
        ListTile(
          title: Text('Komentarz: ${row.komentarz}'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      const SizedBox(height: 15),
    ];
  }

  Widget _buildShopInfo(ExpensesListElementModel row, BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (BuildContext context) {
                var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                if (row.sklep.isEmpty) {
                  return const Text('');
                }
                return Text(isPortrait ? row.sklep : 'Sklep: ${row.sklep}');
              },
            ),
            if (row.kategoria.isNotEmpty)
              Builder(
                builder: (BuildContext context) {
                  var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                  return Text(isPortrait ? row.kategoria : 'Kategoria: ${row.kategoria}');
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                  
                  if (row.kosztDostawy != null && row.kosztDostawy! > 0.0) {
                    return Text(isPortrait ? '${row.kosztDostawy!.toStringAsFixed(2)} zł' : 'Dostawa: ${row.kosztDostawy!.toStringAsFixed(2)} zł');
                  } else {
                    return const Text('');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(ExpensesListElementModel row) {
    return Expanded(
      flex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ilość: ${row.ilosc}'),
          row.miara == null ? const Text('') : Text('Miara: ${row.miara} ml/g'),
          row.iloscWOpakowaniu == null ? const Text('') : Text('W opakowaniu: ${row.iloscWOpakowaniu}'),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(ExpensesListElementModel row) {
    return Expanded(
      flex: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cena: ${row.cena.toStringAsFixed(2)} zł'),
          row.pricePerKg == null ? const Text('') : Text('Cena za kg: ${row.pricePerKg?.toStringAsFixed(2)} zł/kg'),
          row.pricePerPiece == null ? const Text('') : Text('Cena za szt: ${row.pricePerPiece?.toStringAsFixed(2)} zł'),
        ],
      ),
    );
  }

  Widget _buildLinkTile(ExpensesListElementModel row, BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    return ListTile(
      title: Builder(
        builder: (BuildContext context) {
          return Text('Link: ${row.link}', overflow: TextOverflow.ellipsis);
        },
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: () async {
        final Uri url = Uri.parse(row.link);

        if (!await launchUrl(url)) {
          scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Nie udało się otworzyć linku:    $url')));
        }
      },
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
            case SortOption.date || null:
              filteredData.sort((a, b) => a.data.compareTo(b.data));
              break;
            case SortOption.product:
              filteredData.sort((a, b) => a.produkt.compareTo(b.produkt));
              break;
            case SortOption.cost:
              filteredData.sort((a, b) => a.totalCost.compareTo(b.totalCost));
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