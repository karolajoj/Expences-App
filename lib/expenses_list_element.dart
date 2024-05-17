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
  final bool zwrot;
  final String link;
  final String komentarz;

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
    required this.zwrot,
    required this.link,
    required this.komentarz,
  })  : totalCost = _calculateTotalCost(cena, ilosc, kosztDostawy),
        pricePerKg = _calculatePricePerKg(cena, miara, ilosc),
        pricePerPiece = _calculatePricePerPiece(cena, iloscWOpakowaniu);

  static double _calculateTotalCost(double cena, int ilosc, double? kosztDostawy) {
    double koszt = cena * ilosc;
    if (kosztDostawy != null) {
      koszt += kosztDostawy;
    }
    return koszt;
  }

  static double? _calculatePricePerKg(double cena, int? miara, int ilosc) {
    if (miara != null && miara > 0) {
      return cena / miara * 1000; // assuming miara is in grams
    }
    return null;
  }

  static double? _calculatePricePerPiece(double cena, int? iloscWOpakowaniu) {
    if (iloscWOpakowaniu != null && iloscWOpakowaniu > 0) {
      return cena / iloscWOpakowaniu;
    }
    return null;
  }
}