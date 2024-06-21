import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../Repositories/Local Data/expenses_list_element.dart';
import '../../Utils/autocomplete_field.dart';
import '../../Filters/filter_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_utils.dart';

class AddExpensePage extends StatefulWidget {
  final ExpensesListElementModel? expense;
  final Function loadOrRefreshLocalData;
  final GlobalKey<NavigatorState> navigatorKey;

  const AddExpensePage({super.key, this.expense, required this.loadOrRefreshLocalData, required this.navigatorKey});

  @override
  AddExpensePageState createState() => AddExpensePageState();
}

class AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  late DateTime data;
  late String sklep;
  late String kategoria;
  late String produkt;
  late int ilosc;
  late double cena;
  late int? miara;
  late String? miaraUnit;
  late int? iloscWOpakowaniu;
  late double? kosztDostawy;
  late bool zwrot;
  late String link;
  late String komentarz;

  late ValueNotifier<String> shopNotifier;
  late ValueNotifier<String> categoryNotifier;
  late ValueNotifier<String> productNotifier;

  final List<String> miaraUnits = ['g', 'ml', 'mm'];
  late TextEditingController dataController;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    loadAllSuggestions(setState);
    dataController = TextEditingController(text: DateFormat('dd.MM.yyyy').format(data));
  }

  void _initializeFields() {
    if (widget.expense != null) {
      data = widget.expense!.data;
      sklep = widget.expense!.sklep;
      kategoria = widget.expense!.kategoria;
      produkt = widget.expense!.produkt;
      ilosc = widget.expense!.ilosc;
      cena = widget.expense!.cena;
      miara = widget.expense!.miara;
      miaraUnit = widget.expense!.miaraUnit;
      iloscWOpakowaniu = widget.expense!.iloscWOpakowaniu;
      kosztDostawy = widget.expense!.kosztDostawy;
      zwrot = widget.expense!.zwrot;
      link = widget.expense!.link;
      komentarz = widget.expense!.komentarz;
      shopNotifier = ValueNotifier(sklep);
      categoryNotifier = ValueNotifier(kategoria);
      productNotifier = ValueNotifier(produkt);
    } else {
      resetFields(this);
    }

    shopNotifier = ValueNotifier(sklep);
    categoryNotifier = ValueNotifier(kategoria);
    productNotifier = ValueNotifier(produkt);
  }

  @override
  void dispose() {
    shopNotifier.dispose();
    categoryNotifier.dispose();
    productNotifier.dispose();
    dataController.dispose();
    super.dispose();
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: dataController,
      decoration: const InputDecoration(labelText: 'Data'),
      readOnly: true,
      onTap: () async {
        final List<DateTime?>? picked = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            calendarType: CalendarDatePicker2Type.single,
            firstDayOfWeek: 1,
            selectableDayPredicate: (day) => day.isBefore(DateTime.now()), // Blokuje daty w przyszłości
          ),
          dialogSize: const Size(325, 400),
        );
        if (picked != null && picked.isNotEmpty && picked.first != data) {
          setState(() {
            data = picked.first!;
            dataController.text = DateFormat('dd.MM.yyyy').format(data);
          });
        }
      },
    );
  }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: miaraUnit,
      decoration: const InputDecoration(labelText: 'Jednostka miary'),
      items: miaraUnits.map((String unit) {
        return DropdownMenuItem<String>(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          miaraUnit = newValue;
        });
      },
      onSaved: (value) => miaraUnit = value,
    );
  }

  Widget _buildTextFormField({
    required String initialValue,
    required String labelText,
    required Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Dodaj wydatek' : 'Edytuj wydatek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDateField(),
              AutocompleteField(
                options: getAllSklepy(),
                label: 'Sklep',
                valueNotifier: shopNotifier,
                onSelected: (selection) {
                  setState(() {
                    sklep = selection;
                    shopNotifier.value = selection;
                  });
                },
                onClear: () {
                  setState(() {
                    sklep = '';
                    shopNotifier.value = '';
                  });
                },
              ),
              AutocompleteField(
                options: getAllKategorie(),
                label: 'Kategoria',
                valueNotifier: categoryNotifier,
                onSelected: (selection) {
                  setState(() {
                    kategoria = selection;
                    categoryNotifier.value = selection;
                  });
                },
                onClear: () {
                  setState(() {
                    kategoria = '';
                    categoryNotifier.value = '';
                  });
                },
              ),
              AutocompleteField(
                options: getAllProdukty(),
                label: 'Produkt',
                valueNotifier: productNotifier,
                onSelected: (selection) {
                  setState(() {
                    produkt = selection;
                    productNotifier.value = selection;
                  });
                },
                onClear: () {
                  setState(() {
                    produkt = '';
                    productNotifier.value = '';
                  });
                },
              ),
              _buildTextFormField(
                initialValue: ilosc.toString(),
                labelText: 'Ilość',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onSaved: (value) {
                  int? parsedValue = int.tryParse(value ?? '1');
                  if (parsedValue == null || parsedValue <= 0) {
                    ilosc = 1;
                  } else {
                    ilosc = parsedValue;
                  }
                },
              ),
              _buildTextFormField(
                initialValue: cena.toString(),
                labelText: 'Cena',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\.,/*]')),
                ],
                onSaved: (value) {
                  double parsedValue = double.parse(calculatePrice(value ?? '0.0'));
                  if (parsedValue < 0) {
                    cena = 0.0;
                  } else {
                    cena = parsedValue;
                  }
                },
              ),
              _buildDropdownButtonFormField(),
              _buildTextFormField(
                initialValue: miara == null ? "" :miara.toString(),
                labelText: 'Miara',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onSaved: (value) {
                  int? parsedValue = value != null ? int.tryParse(value) : null;
                  if (parsedValue == null || parsedValue <= 0.0) {
                    miara = null;
                  } else {
                    miara = parsedValue;
                  }
                },
              ),
              _buildTextFormField(
                initialValue: iloscWOpakowaniu == null ? "" :iloscWOpakowaniu.toString(),
                labelText: 'Ilość w opakowaniu',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onSaved: (value) {
                  int? parsedValue = value != null ? int.tryParse(value) : null;
                  if (parsedValue == null || parsedValue <= 0.0) {
                    iloscWOpakowaniu = null;
                  } else {
                    iloscWOpakowaniu = parsedValue;
                  }
                },
              ),
              _buildTextFormField(
                initialValue: kosztDostawy == null ? "" : kosztDostawy.toString(),
                labelText: 'Koszt dostawy',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\.,]')),
                ],
                onSaved: (value) {
                  double? parsedValue = value != null ? double.tryParse(value) : null;
                  if (parsedValue == null || parsedValue <= 0.0) {
                    kosztDostawy = null;
                  } else {
                    kosztDostawy = parsedValue;
                  }
                },
              ),
              Row(
                children: [
                  const Text('Zwrot'),
                  Checkbox(
                    value: zwrot,
                    onChanged: (value) {
                      setState(() {
                        zwrot = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              _buildTextFormField(
                initialValue: link,
                labelText: 'Link',
                onSaved: (value) => link = value ?? '',
              ),
              _buildTextFormField(
                initialValue: komentarz,
                labelText: 'Komentarz',
                onSaved: (value) => komentarz = value ?? '',
              ),
              ElevatedButton(
                onPressed: () => saveExpense(this, _formKey, widget.expense, widget.loadOrRefreshLocalData, widget.navigatorKey, shopNotifier, categoryNotifier, productNotifier), // Użycie przeniesionej metody
                child: const Text('Zapisz'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(widget.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(widget.expense == null ? 'Anulowano dodawanie wydatku' : 'Anulowano edycję wydatku')));
                },
                child: const Text('Anuluj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}