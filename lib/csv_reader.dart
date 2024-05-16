import 'package:flutter/material.dart';
import 'expenses_list_element.dart';
import 'csv_filter_dialog.dart';
import 'csv_loader.dart';

class CSVReader extends StatefulWidget {
  const CSVReader({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CSVReaderState createState() => _CSVReaderState();
}

class _CSVReaderState extends State<CSVReader> {
  List<ExpensesListElementModel> csvData = [];
  List<ExpensesListElementModel> filteredData = [];
  int sum = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Reader'),
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

                        // Tu możesz korzystać z danych z obiektu ExpensesListElementModel zamiast bezpośrednio z listy csvData

                        String currentDay = row.data.toString();
                        String? prevDay = index > 0
                            ? csvData[index - 1].data.toString()
                            : null;

                        // Sprawdź, czy aktualny dzień jest taki sam jak poprzedni element
                        int isDifferentDay = currentDay != prevDay ? 1 : 0;

                        sum = sum + isDifferentDay;

                        Color? rowColor =
                            sum % 2 == 0 ? Colors.grey[300] : Colors.blue[100];

                        return ExpansionTile(
                          title: Row(
                            children: [
                              SizedBox(
                                width:
                                    100, // Stała szerokość dla pierwszej kolumny
                                child: Text(
                                    row.data.toString().split(' ')[0]),
                              ),
                              Expanded(
                                child: Text(
                                    row.produkt), // Automatyczna szerokość dla środkowej kolumny
                              ),
                              SizedBox(
                                width:
                                    80, // Stała szerokość dla ostatniej kolumny
                                child: Text(
                                    '${row.totalCost.toStringAsFixed(2)} zł'),
                              ),
                            ],
                          ),
                          trailing: const SizedBox
                              .shrink(), // Usunięcie ikony rozwijania
                          collapsedBackgroundColor: rowColor,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.red, // Kolor tła czerwony
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                    color: Colors.red, // Kolor tła czerwony
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Ilość: ${row.ilosc}'),
                                        Text('Miara: ${row.miara}'),
                                        Text(
                                            'W opakowaniu: ${row.iloscWOpakowaniu}'),
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
                              title: Text(
                                  'Ilość w opakowaniu: ${row.iloscWOpakowaniu}'),
                            ),
                            ListTile(
                              title:
                                  Text('Koszt dostawy: ${row.kosztDostawy} zł'),
                            ),
                          ],
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
      });
    }).loadCSV(context);
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

        return withinDateRange && matchesProductFilter && matchesShopFilter && matchesCategoryFilter;
      }).toList();
    });
  }
}
