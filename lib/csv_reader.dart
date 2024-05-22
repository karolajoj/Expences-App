import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'expenses_list_element.dart';
import 'csv_filter_dialog.dart';
import 'csv_loader.dart';
import 'package:intl/intl.dart';

class CSVReader extends StatefulWidget {
  const CSVReader({super.key});

  @override
  CSVReaderState createState() => CSVReaderState();
}

class CSVReaderState extends State<CSVReader> {
  List<ExpensesListElementModel> csvData = [];
  List<ExpensesListElementModel> filteredData = [];
  List<Key> expansionTileKeys = [];
  Map<String, Color> dateColorMap = {};

  @override
  void initState() {
    super.initState();
    _initExpansionTileKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadCSV(context),
        tooltip: 'Wczytaj CSV',
        child: const Icon(Icons.folder_open),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Lista wydatków'),
      actions: [
        IconButton(
          onPressed: () => _openFilterDialog(context),
          icon: const Icon(Icons.filter_alt),
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
        title: _buildTitle(currentDay, row),
        children: _buildExpansionChildren(row, context),
      ),
    );
  }

  Widget _buildTrailingText(ExpensesListElementModel row) {
    return Text(
      row.zwrot ? 'Zwrócono' : '${row.totalCost.toStringAsFixed(2)} zł',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildTitle(String currentDay, ExpensesListElementModel row) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(currentDay)),
        Container(width: 1, height: 24, color: Colors.grey, margin: const EdgeInsets.symmetric(horizontal: 8)),
        Expanded(child: Text(row.produkt, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  List<Widget> _buildExpansionChildren(ExpensesListElementModel row, BuildContext context) {
    return [
      Row(
        children: [
          if (row.sklep.isNotEmpty) _buildShopInfo(row, context),
          _buildProductDetails(row),
          _buildPriceDetails(row),
          SizedBox(width: 10, child: Container(color: Colors.red)),
        ],
      ),
      if (row.link.isNotEmpty) _buildLinkTile(row, context),
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
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (BuildContext context) {
                var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
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
            if (row.kosztDostawy != null && row.kosztDostawy! > 0)
              Builder(
                builder: (BuildContext context) {
                  var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                  return Text(
                    isPortrait ? '${row.kosztDostawy?.toStringAsFixed(2)} zł' : 'Dostawa: ${row.kosztDostawy?.toStringAsFixed(2)} zł',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(ExpensesListElementModel row) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ilość: ${row.ilosc}'),
          if (row.miara != null) Text('Miara: ${row.miara} ml/g'),
          if (row.iloscWOpakowaniu != null) Text('W opakowaniu: ${row.iloscWOpakowaniu}'),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(ExpensesListElementModel row) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cena: ${row.cena.toStringAsFixed(2)} zł'),
          if (row.pricePerKg != null) Text('Cena za kg: ${row.pricePerKg?.toStringAsFixed(2)} zł/kg'),
          if (row.pricePerPiece != null) Text('Cena za sztukę: ${row.pricePerPiece?.toStringAsFixed(2)} zł'),
        ],
      ),
    );
  }

  Widget _buildLinkTile(ExpensesListElementModel row, BuildContext context) {
    return ListTile(
      title: Builder(
        builder: (BuildContext context) {
          var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
          var maxLength = isPortrait ? 51 : 97;
          var displayedLink = row.link.length > maxLength ? '${row.link.substring(0, maxLength)}...' : row.link;
          return Text('Link: $displayedLink', overflow: TextOverflow.ellipsis);
        },
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: () async {
        final Uri url = Uri.parse(row.link);

        if (!await launchUrl(url)) {
          if (context.mounted) {
            _showErrorDialog(context, 'Could not launch $url');
          }
        }
      },
    );
  }

  void _loadCSV(BuildContext context) {
    CSVLoader((data) {
      setState(() {
        csvData = data;
        filteredData = data;
        dateColorMap.clear();

        // Initialize dateColorMap
        for (var row in csvData) {
          String currentDay = DateFormat('dd.MM.yyyy').format(row.data);
          if (!dateColorMap.containsKey(currentDay)) {
            Color newColor = dateColorMap.isEmpty || dateColorMap.values.last == Colors.grey[350]
                ? Colors.blue[100]!
                : Colors.grey[350]!;
            dateColorMap[currentDay] = newColor;
          }
        }

        _applyDefaultFilters();
      });
    }).loadCSV(context);
  }

  void _applyDefaultFilters() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();
    _applyFilters(startDate, endDate, null, null, null);
  }

  void _openFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CSVFilterDialog((startDate, endDate, productFilter, shopFilter, categoryFilter) {
          _applyFilters(startDate, endDate, productFilter, shopFilter, categoryFilter);
        });
      },
    );
  }

  void _applyFilters(DateTime? startDate, DateTime? endDate, String? productFilter, String? shopFilter, String? categoryFilter) {
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
        _updateExpansionTileKeys();
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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