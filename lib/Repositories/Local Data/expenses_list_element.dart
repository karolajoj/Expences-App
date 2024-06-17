import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expenses_list_element.g.dart';

@HiveType(typeId: 0)
class ExpensesListElementModel {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final String? firebaseId;

  @HiveField(2)
  final DateTime data;

  @HiveField(3)
  final String sklep;

  @HiveField(4)
  final String kategoria;

  @HiveField(5)
  final String produkt;

  @HiveField(6)
  final int ilosc;

  @HiveField(7)
  final double cena;

  @HiveField(8)
  final int? miara;

  @HiveField(9)
  final String? miaraUnit;

  @HiveField(10)
  final int? iloscWOpakowaniu;

  @HiveField(11)
  final double? pricePerPiece;

  @HiveField(12)
  final double? pricePerKg;

  @HiveField(13)
  final double? kosztDostawy;

  @HiveField(14)
  final bool zwrot;

  @HiveField(15)
  final double totalCost;

  @HiveField(16)
  final String link;

  @HiveField(17)
  final String komentarz;

  @HiveField(18)
  late bool? toBeSent; // Meaning added localy but not yet on server

  @HiveField(18)
  late bool? toBeUpdated; // Meaning modified localy but not yet on server

  @HiveField(20)
  late bool? toBeDeleted; // Meaning deleted localy but not yet on server

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
    this.toBeSent = false,
    this.toBeUpdated = false,
    this.toBeDeleted = false,
  })  : totalCost = _calculateTotalCost(cena, ilosc, kosztDostawy),
        pricePerKg = _calculatePricePerKg(cena, kosztDostawy, miara, ilosc),
        pricePerPiece = _calculatePricePerPiece(cena, kosztDostawy, iloscWOpakowaniu, ilosc),
        localId = localId ?? const Uuid().v4();

  static double _calculateTotalCost(double cena, int ilosc, double? kosztDostawy) {
    double koszt = cena * ilosc;
    if (kosztDostawy != null) {
      koszt += kosztDostawy;
    }
    return koszt;
  }

  static double? _calculatePricePerKg(double cena, double? kosztDostawy, int? miara, int ilosc) {
    if (miara != null && miara > 0) {
      return _calculateTotalCost(cena, ilosc, kosztDostawy) / (miara * ilosc) * 1000;
    }
    return null;
  }

  static double? _calculatePricePerPiece(double cena, double? kosztDostawy, int? iloscWOpakowaniu, int ilosc) {
    if (iloscWOpakowaniu != null && iloscWOpakowaniu > 0) {
      return _calculateTotalCost(cena, ilosc, kosztDostawy) / iloscWOpakowaniu;
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
      'toBeSent': toBeSent,
      'toBeUpdated': toBeUpdated,
      'toBeDeleted': toBeDeleted,
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
      toBeSent: map['toBeSent'] ?? false,
      toBeUpdated: map['toBeUpdated'] ?? false,
      toBeDeleted: map['toBeDeleted'] ?? false,
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
    bool? toBeSent,
    bool? toBeUpdated,
    bool? toBeDeleted,
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
      toBeSent: toBeSent ?? this.toBeSent,
      toBeUpdated: toBeUpdated ?? this.toBeUpdated,
      toBeDeleted: toBeDeleted ?? this.toBeDeleted,
    );
  }
}