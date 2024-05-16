class ExpensesListElementModel {
  final DateTime data;
  final String sklep;
  final String kategoria;
  final String produkt;
  final int ilosc;
  final double cena;
  final int? miara;
  final int? iloscWOpakowaniu;
  final double? kosztDostawy;
  final double totalCost;
  final double? pricePerKg;
  final double? pricePerPiece;

  ExpensesListElementModel({
    required this.data,
    required this.sklep,
    required this.kategoria,
    required this.produkt,
    required this.ilosc,
    required this.cena,
    required this.miara,
    required this.iloscWOpakowaniu,
    required this.kosztDostawy,
    required this.totalCost,
    required this.pricePerKg,
    required this.pricePerPiece,
  });
}
