import 'package:hive/hive.dart';

part 'expenses_list_element.g.dart';

@HiveType(typeId: 0)
class ExpensesListElementModel {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final DateTime data;

  @HiveField(2)
  final String sklep;

  @HiveField(3)
  final String kategoria;

  @HiveField(4)
  final String produkt;

  @HiveField(5)
  final int ilosc;

  @HiveField(6)
  final double cena;

  @HiveField(7)
  final int? miara;

  @HiveField(8)
  final String? miaraUnit;

  @HiveField(9)
  final int? iloscWOpakowaniu;

  @HiveField(10)
  final double? kosztDostawy;

  @HiveField(11)
  final double totalCost;

  @HiveField(12)
  final double? pricePerKg;

  @HiveField(13)
  final double? pricePerPiece;

  @HiveField(14)
  final bool zwrot;

  @HiveField(15)
  final String link;

  @HiveField(16)
  final String komentarz;

  @HiveField(17)
  final String? firebaseId;

  ExpensesListElementModel({
    String? localId,
    this.firebaseId,
    required this.data,
    required this.sklep,
    required this.kategoria,
    required this.produkt,
    required this.ilosc,
    required this.cena,
    required this.miara,
    this.miaraUnit,
    required this.iloscWOpakowaniu,
    required this.kosztDostawy,
    required this.zwrot,
    required this.link,
    required this.komentarz,
  })  : totalCost = _calculateTotalCost(cena, ilosc, kosztDostawy),
        pricePerKg = _calculatePricePerKg(cena, kosztDostawy, miara),
        pricePerPiece = _calculatePricePerPiece(cena, kosztDostawy, iloscWOpakowaniu),
        localId = localId ?? DateTime.now().millisecondsSinceEpoch.toString();

  static double _calculateTotalCost(double cena, int ilosc, double? kosztDostawy) {
    double koszt = cena * ilosc;
    if (kosztDostawy != null) {
      koszt += kosztDostawy;
    }
    return koszt;
  }

  static double? _calculatePricePerKg(double cena, double? kosztDostawy, int? miara) {
    if (miara != null && miara > 0) {
      kosztDostawy ??= 0;
      return (cena + kosztDostawy) / miara * 1000;
    }
    return null;
  }

  static double? _calculatePricePerPiece(double cena, double? kosztDostawy, int? iloscWOpakowaniu) {
    if (iloscWOpakowaniu != null && iloscWOpakowaniu > 0) {
      kosztDostawy ??= 0;
      return (cena + kosztDostawy) / iloscWOpakowaniu;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'firebaseId': firebaseId,
      'data': data.toIso8601String(),
      'sklep': sklep,
      'kategoria': kategoria,
      'produkt': produkt,
      'ilosc': ilosc,
      'cena': cena,
      'miara': miara,
      'miaraUnit': miaraUnit,
      'iloscWOpakowaniu': iloscWOpakowaniu,
      'kosztDostawy': kosztDostawy,
      'zwrot': zwrot,
      'link': link,
      'komentarz': komentarz,
    };
  }

  factory ExpensesListElementModel.fromMap(Map<String, dynamic> map) {
    return ExpensesListElementModel(
      localId: map['localId'],
      firebaseId: map['firebaseId'],
      data: DateTime.parse(map['data']),
      sklep: map['sklep'],
      kategoria: map['kategoria'],
      produkt: map['produkt'],
      ilosc: map['ilosc'],
      cena: map['cena'],
      miara: map['miara'],
      miaraUnit: map['miaraUnit'],
      iloscWOpakowaniu: map['iloscWOpakowaniu'],
      kosztDostawy: map['kosztDostawy'],
      zwrot: map['zwrot'] == "Tak",
      link: map['link'],
      komentarz: map['komentarz'],
    );
  }

  ExpensesListElementModel copyWith({
    String? localId,
    String? firebaseId,
    DateTime? data,
    String? sklep,
    String? kategoria,
    String? produkt,
    int? ilosc,
    double? cena,
    int? miara,
    String? miaraUnit,
    int? iloscWOpakowaniu,
    double? kosztDostawy,
    bool? zwrot,
    String? link,
    String? komentarz,
  }) {
    return ExpensesListElementModel(
      localId: localId ?? this.localId,
      firebaseId: firebaseId ?? this.firebaseId,
      data: data ?? this.data,
      sklep: sklep ?? this.sklep,
      kategoria: kategoria ?? this.kategoria,
      produkt: produkt ?? this.produkt,
      ilosc: ilosc ?? this.ilosc,
      cena: cena ?? this.cena,
      miara: miara ?? this.miara,
      miaraUnit: miaraUnit ?? this.miaraUnit,
      iloscWOpakowaniu: iloscWOpakowaniu ?? this.iloscWOpakowaniu,
      kosztDostawy: kosztDostawy ?? this.kosztDostawy,
      zwrot: zwrot ?? this.zwrot,
      link: link ?? this.link,
      komentarz: komentarz ?? this.komentarz,
    );
  }
}