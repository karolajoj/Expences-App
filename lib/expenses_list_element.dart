class ExpensesListElement {
  final dynamic data;
  final dynamic sklep;
  final dynamic kategoria;
  final dynamic produkt;
  final dynamic ilosc;
  final dynamic cenaZaSztuke;
  final dynamic iloscWMiara;
  final dynamic iloscWOpakowaniu;
  final dynamic kosztDostawy;

  ExpensesListElement({
    required this.data,
    required this.sklep,
    required this.kategoria,
    required this.produkt,
    required this.ilosc,
    required this.cenaZaSztuke,
    required this.iloscWMiara,
    required this.iloscWOpakowaniu,
    required this.kosztDostawy,
  });

  @override
  String toString() {
    return 'Data: $data, Sklep: $sklep, Kategoria: $kategoria, Produkt: $produkt, '
        'Ilość: $ilosc, Cena za sztukę: $cenaZaSztuke, Ilość w (ml,g,mm,cm): $iloscWMiara, '
        'Ilość w opakowaniu: $iloscWOpakowaniu, Koszt dostawy: $kosztDostawy';
  }
}