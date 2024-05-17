import 'package:flutter/material.dart';
import 'expenses_list_element.dart';
import 'csv_filter_dialog.dart';
import 'csv_loader.dart';
import 'package:intl/intl.dart';

class CSVReader extends StatefulWidget {
  const CSVReader({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CSVReaderState createState() => _CSVReaderState();
}

class _CSVReaderState extends State<CSVReader> {
  List<ExpensesListElementModel> csvData = [];
  List<ExpensesListElementModel> filteredData = [];
  Map<String, Color> dateColorMap = {};
  Map<String, bool> dateShadeMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista wydatków'),
        actions: [
          IconButton(
            onPressed: () => _openFilterDialog(context),
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Center(
        child: csvData.isEmpty
            ? const Text('Brak danych CSV')
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final row = filteredData[index];

                        String currentDay = DateFormat('dd.MM.yyyy').format(row.data);

                        // Check if the color for the current date is already in the map
                        if (!dateColorMap.containsKey(currentDay)) {
                          // If not, add the color to the map, alternating colors
                          Color newColor = dateColorMap.isEmpty || dateColorMap.values.last == Colors.grey[300]
                              ? Colors.blue[100]!
                              : Colors.grey[300]!;
                          dateColorMap[currentDay] = newColor;
                          dateShadeMap[currentDay] = true; // Start with true for lighter shade
                        }

                        // Determine the shade to use for this row
                        bool isLighterShade = dateShadeMap[currentDay]!;
                        Color rowColor = isLighterShade
                            ? dateColorMap[currentDay]!
                            : dateColorMap[currentDay]!.withOpacity(0.6);

                        // Toggle the shade for the next row of the same date
                        dateShadeMap[currentDay] = !isLighterShade;

                        return Container(
                          color: rowColor,
                          child: ExpansionTile(
                            trailing: Text(
                              '${row.totalCost.toStringAsFixed(2)} zł',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            title: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(currentDay),
                                ),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Colors.grey,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                Expanded(
                                  child: Text(row.produkt),
                                ),
                              ],
                            ),
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Colors.red,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Sklep: ${row.sklep}'),
                                          Text('Kategoria: ${row.kategoria}'),
                                          Text('Dostawa: ${row.kosztDostawy} zł'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.red,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Ilość: ${row.ilosc}'),
                                          Text('Miara: ${row.miara}'),
                                          Text('W opakowaniu: ${row.iloscWOpakowaniu}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ListTile(
                                title: Text('Ilość w miarę: ${row.miara}'),
                              ),
                              ListTile(
                                title: Text('Ilość w opakowaniu: ${row.iloscWOpakowaniu}'),
                              ),
                              ListTile(
                                title: Text('Koszt dostawy: ${row.kosztDostawy} zł'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _loadCSV(context),
        tooltip: 'Wczytaj CSV',
        child: const Icon(Icons.folder_open),
      ),
    );
  }

  void _loadCSV(BuildContext context) {
    CSVLoader((data) {
      setState(() {
        csvData = data;
        filteredData = data;
        dateColorMap.clear();
        dateShadeMap.clear();
        _applyDefaultFilters();
      });
    }).loadCSV(context);
  }

  void _applyDefaultFilters() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
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
      });
    }
  }
}
