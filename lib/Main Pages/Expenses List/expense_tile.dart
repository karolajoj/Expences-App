import '../../Repositories/Local Data/expenses_list_element.dart';
import 'package:expenses_app_project/Main%20Pages/Expenses%20List/add_expense_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseTile extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final ValueChanged<bool> onExpansionChanged;
  final Map<String, Color> dateColorMap;
  final ExpensesListElementModel row;
  final Set<int> expandedTiles;
  final int index;

  const ExpenseTile({super.key, 
    required this.row,
    required this.index,
    required this.dateColorMap,
    required this.expandedTiles,
    required this.onExpansionChanged,
    required this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context) {
    String currentDay = DateFormat('dd.MM.yyyy').format(row.data);
    Color rowColor = index.isEven ? dateColorMap[currentDay]! : dateColorMap[currentDay]!.withOpacity(0.6);

    return Container(
      color: rowColor,
      child: ExpansionTile(
        key: Key(row.localId),
        trailing: _buildTrailingText(),
        title: _buildTitle(currentDay),
        onExpansionChanged: onExpansionChanged,
        children: _buildExpansionChildren(context),
      ),
    );
  }

  Widget _buildTrailingText() {
    return Text(
      row.zwrot ? 'Zwrócono' : '${row.totalCost.toStringAsFixed(2)} zł',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildTitle(String currentDay) {
    bool isExpanded = expandedTiles.contains(index);

    return Row(
      children: [
        Text(currentDay),
        Container(width: 1, height: 24, color: Colors.grey, margin: const EdgeInsets.symmetric(horizontal: 8)),
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

  List<Widget> _buildExpansionChildren(BuildContext context) {
    return [
      Row(
        children: [
          _buildShopInfo(context),
          _buildProductDetails(),
          _buildPriceDetails(),
          SizedBox(width: 10, child: Container(color: Colors.red)),
        ],
      ),
      if (row.link.isNotEmpty) _buildLinkTile(context),
      if (row.komentarz.isNotEmpty && row.komentarz.trim().isNotEmpty)
        ListTile(
          title: Text('Komentarz: ${row.komentarz}'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      const SizedBox(height: 15),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExpensePage(expense: row,),
                ),
              );
            },
            child: const Icon(Icons.edit, color: Colors.blue),
          ),
          const SizedBox(width: 15),
        ],
      ),
      const SizedBox(height: 15),
    ];
  }

  Widget _buildShopInfo(BuildContext context) {
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

  Widget _buildProductDetails() {
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

  Widget _buildPriceDetails() {
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

  Widget _buildLinkTile(BuildContext context) {
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
}