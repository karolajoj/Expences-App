import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

                        String currentDay =
                            DateFormat('dd.MM.yyyy').format(row.data);

                        // Check if the color for the current date is already in the map
                        if (!dateColorMap.containsKey(currentDay)) {
                          // If not, add the color to the map, alternating colors
                          Color newColor = dateColorMap.isEmpty ||
                                  dateColorMap.values.last == Colors.grey[350]
                              ? Colors.blue[100]!
                              : Colors.grey[350]!;
                          dateColorMap[currentDay] = newColor;
                          dateShadeMap[currentDay] =
                              true; // Start with true for lighter shade
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
                              row.zwrot
                                  ? 'Zwrócono'
                                  : '${row.totalCost.toStringAsFixed(2)} zł',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
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
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                Expanded(
                                  child: Text(row.produkt),
                                ),
                              ],
                            ),
                            children: [
                              Row(
                                children: [
                                  // SizedBox(
                                  //     width: 50,
                                  //     child: Container(color: Colors.red)),
                                  if (row.sklep.isNotEmpty) ...[
                                    Expanded(
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Builder(
                                              builder: (BuildContext context) {
                                                var isPortrait =
                                                    MediaQuery.of(context)
                                                            .orientation ==
                                                        Orientation.portrait;
                                                return Text(isPortrait
                                                    ? row.sklep
                                                    : 'Sklep: ${row.sklep}');
                                              },
                                            ),
                                            if (row.kategoria.isNotEmpty)
                                              Builder(
                                                builder:
                                                    (BuildContext context) {
                                                  var isPortrait =
                                                      MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.portrait;
                                                  return Text(isPortrait
                                                      ? row.kategoria
                                                      : 'Kategoria: ${row.kategoria}');
                                                },
                                              ),
                                            if (row.kosztDostawy != null &&
                                                row.kosztDostawy! > 0)
                                              Builder(
                                                builder:
                                                    (BuildContext context) {
                                                  var isPortrait =
                                                      MediaQuery.of(context)
                                                              .orientation ==
                                                          Orientation.portrait;
                                                  return Text(isPortrait
                                                      ? '${row.kosztDostawy?.toStringAsFixed(2)} zł'
                                                      : 'Dostawa: ${row.kosztDostawy?.toStringAsFixed(2)} zł');
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Expanded(child: Container()),
                                  ...[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Ilość: ${row.ilosc}'),
                                          if (row.miara != null)
                                            Text('Miara: ${row.miara} ml/g'),
                                          if (row.iloscWOpakowaniu != null)
                                            Text(
                                                'W opakowaniu: ${row.iloscWOpakowaniu}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // Expanded(child: Container()),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Cena: ${row.cena.toStringAsFixed(2)} zł'),
                                        if (row.pricePerKg != null)
                                          Text(
                                              'Cena za kg: ${row.pricePerKg?.toStringAsFixed(2)} zł/kg'),
                                        if (row.pricePerPiece != null)
                                          Text(
                                              'Cena za sztukę: ${row.pricePerPiece?.toStringAsFixed(2)} zł'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      // width: 50,
                                      width: 10,
                                      child: Container(color: Colors.red)),
                                ],
                              ),
                              if (row.link.isNotEmpty)
                                ListTile(
                                  title: Text('Link: ${row.link}'),
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                  onTap: () async {
                                    final Uri url = Uri.parse(row.link);

                                    if (!await launchUrl(url)) {
                                      throw Exception('Could not launch $url');
                                    }
                                  },
                                ),
                              if (row.komentarz.isNotEmpty &&
                                  row.komentarz.trim().isNotEmpty)
                                ListTile(
                                  title: Text('Komentarz: ${row.komentarz}'),
                                  contentPadding:
                                      const EdgeInsets.only(left: 20),
                                ),
                              const SizedBox(height: 15), // Padding at the end
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
        return CSVFilterDialog(
            (startDate, endDate, productFilter, shopFilter, categoryFilter) {
          _applyFilters(
              startDate, endDate, productFilter, shopFilter, categoryFilter);
        });
      },
    );
  }

  void _applyFilters(DateTime? startDate, DateTime? endDate,
      String? productFilter, String? shopFilter, String? categoryFilter) {
    if (csvData.isNotEmpty) {
      setState(() {
        filteredData = csvData.where((element) {
          bool withinDateRange = true;
          bool matchesProductFilter = true;
          bool matchesShopFilter = true;
          bool matchesCategoryFilter = true;

          if (startDate != null && endDate != null) {
            withinDateRange = element.data.isAfter(startDate) &&
                element.data.isBefore(endDate);
          }

          if (productFilter != null) {
            matchesProductFilter = element.produkt
                .toLowerCase()
                .contains(productFilter.toLowerCase());
          }

          if (shopFilter != null) {
            matchesShopFilter =
                element.sklep.toLowerCase().contains(shopFilter.toLowerCase());
          }

          if (categoryFilter != null) {
            matchesCategoryFilter = element.kategoria
                .toLowerCase()
                .contains(categoryFilter.toLowerCase());
          }

          return withinDateRange &&
              matchesProductFilter &&
              matchesShopFilter &&
              matchesCategoryFilter;
        }).toList();
      });
    }
  }
}
