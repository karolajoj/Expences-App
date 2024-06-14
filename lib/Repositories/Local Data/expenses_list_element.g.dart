// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_list_element.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpensesListElementModelAdapter
    extends TypeAdapter<ExpensesListElementModel> {
  @override
  final int typeId = 0;

  @override
  ExpensesListElementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpensesListElementModel(
      localId: fields[0] as String?,
      firebaseId: fields[17] as String?,
      data: fields[1] as DateTime,
      sklep: fields[2] as String,
      kategoria: fields[3] as String,
      produkt: fields[4] as String,
      ilosc: fields[5] as int,
      cena: fields[6] as double,
      miara: fields[7] as int?,
      miaraUnit: fields[8] as String?,
      iloscWOpakowaniu: fields[9] as int?,
      kosztDostawy: fields[10] as double?,
      zwrot: fields[14] as bool,
      link: fields[15] as String,
      komentarz: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpensesListElementModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.sklep)
      ..writeByte(3)
      ..write(obj.kategoria)
      ..writeByte(4)
      ..write(obj.produkt)
      ..writeByte(5)
      ..write(obj.ilosc)
      ..writeByte(6)
      ..write(obj.cena)
      ..writeByte(7)
      ..write(obj.miara)
      ..writeByte(8)
      ..write(obj.miaraUnit)
      ..writeByte(9)
      ..write(obj.iloscWOpakowaniu)
      ..writeByte(10)
      ..write(obj.kosztDostawy)
      ..writeByte(11)
      ..write(obj.totalCost)
      ..writeByte(12)
      ..write(obj.pricePerKg)
      ..writeByte(13)
      ..write(obj.pricePerPiece)
      ..writeByte(14)
      ..write(obj.zwrot)
      ..writeByte(15)
      ..write(obj.link)
      ..writeByte(16)
      ..write(obj.komentarz)
      ..writeByte(17)
      ..write(obj.firebaseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpensesListElementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
