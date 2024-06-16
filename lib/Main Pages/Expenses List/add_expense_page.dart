import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../Repositories/Local Data/expenses_list_element.dart';
import 'package:flutter/material.dart';
import '../../autocomplete_field.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../utils.dart';

class AddExpensePage extends StatefulWidget {
  final ExpensesListElementModel? expense;

  const AddExpensePage({super.key, this.expense});

  @override
  AddExpensePageState createState() => AddExpensePageState();
}

class AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _data;
  late String _sklep;
  late String _kategoria;
  late String _produkt;
  late int _ilosc;
  late double _cena;
  late int? _miara;
  late String? _miaraUnit;
  late int? _iloscWOpakowaniu;
  late double? _kosztDostawy;
  late bool _zwrot;
  late String _link;
  late String _komentarz;

  late ValueNotifier<String> shopNotifier;
  late ValueNotifier<String> categoryNotifier;
  late ValueNotifier<String> productNotifier;

  final List<String> miaraUnits = ['kg', 'g', 'ml', 'l', 'szt'];
  late TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadSuggestions();
    _dataController = TextEditingController(text: DateFormat('dd.MM.yyyy').format(_data));
  }

  void _initializeFields() {
    if (widget.expense != null) {
      _data = widget.expense!.data;
      _sklep = widget.expense!.sklep;
      _kategoria = widget.expense!.kategoria;
      _produkt = widget.expense!.produkt;
      _ilosc = widget.expense!.ilosc;
      _cena = widget.expense!.cena;
      _miara = widget.expense!.miara;
      _miaraUnit = widget.expense!.miaraUnit;
      _iloscWOpakowaniu = widget.expense!.iloscWOpakowaniu;
      _kosztDostawy = widget.expense!.kosztDostawy;
      _zwrot = widget.expense!.zwrot;
      _link = widget.expense!.link;
      _komentarz = widget.expense!.komentarz;
    } else {
      _resetFields();
    }

    shopNotifier = ValueNotifier(_sklep);
    categoryNotifier = ValueNotifier(_kategoria);
    productNotifier = ValueNotifier(_produkt);
  }

  void _resetFields() {
    _data = DateTime.now();
    _sklep = '';
    _kategoria = '';
    _produkt = '';
    _ilosc = 1;
    _cena = 0.0;
    _miara = null;
    _miaraUnit = null;
    _iloscWOpakowaniu = null;
    _kosztDostawy = null;
    _zwrot = false;
    _link = '';
    _komentarz = '';
  }

  Future<void> _loadSuggestions() async {
    await loadAllSuggestions();
    setState(() {});
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final newExpense = ExpensesListElementModel(
        localId: widget.expense?.localId,
        firebaseId: widget.expense?.firebaseId,
        data: _data,
        sklep: _sklep,
        kategoria: _kategoria,
        produkt: _produkt,
        ilosc: _ilosc,
        cena: _cena,
        miara: _miara,
        miaraUnit: _miaraUnit,
        iloscWOpakowaniu: _iloscWOpakowaniu,
        kosztDostawy: _kosztDostawy,
        zwrot: _zwrot,
        link: _link,
        komentarz: _komentarz,
      );

      await _saveExpenseLocally(newExpense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.expense == null ? 'Wydatek dodany pomyślnie' : 'Wydatek zaktualizowany pomyślnie')));
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _saveExpenseLocally(ExpensesListElementModel expense) async {
    var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
    await box.put(expense.localId, expense);
  }

  String _calculatePrice(String input) {
    input = input.replaceAll(',', '.');
    if (input.contains('/')) {
      var parts = input.split('/');
      if (parts.length == 2) {
        double num = double.tryParse(parts[0]) ?? 0;
        double denom = double.tryParse(parts[1]) ?? 1;
        return (num / denom).toString();
      }
    } else if (input.contains('*')) {
      var parts = input.split('*');
      if (parts.length == 2) {
        double num1 = double.tryParse(parts[0]) ?? 0;
        double num2 = double.tryParse(parts[1]) ?? 0;
        return (num1 * num2).toString();
      }
    }
    return double.tryParse(input)?.toString() ?? '0.0';
  }

  @override
  void dispose() {
    shopNotifier.dispose();
    categoryNotifier.dispose();
    productNotifier.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dataController,
      decoration: const InputDecoration(labelText: 'Data'),
      readOnly: true,
      onTap: () async {
        final List<DateTime?>? picked = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            calendarType: CalendarDatePicker2Type.single,
            firstDayOfWeek: 1,
          ),
          dialogSize: const Size(325, 400),
        );
        if (picked != null && picked.isNotEmpty && picked.first != _data) {
          setState(() {
            _data = picked.first!;
            _dataController.text = DateFormat('dd.MM.yyyy').format(_data);
          });
        }
      },
    );
  }


  // Widget _buildAutocompleteField(String label, ValueNotifier<String> notifier, List<String> options, Function(String) onSelected) {
  //   return AutocompleteField(
  //     options: options,
  //     label: label,
  //     valueNotifier: notifier,
  //     onSelected: (selection) {
  //       setState(() {
  //         onSelected(selection);
  //         notifier.value = selection;
  //       });
  //     },
  //     onClear: () {
  //       setState(() {
  //         onSelected('');
  //         notifier.value = '';
  //       });
  //     },
  //   );
  // }

  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _miaraUnit,
      decoration: const InputDecoration(labelText: 'Jednostka miary'),
      items: miaraUnits.map((String unit) {
        return DropdownMenuItem<String>(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _miaraUnit = newValue;
        });
      },
      onSaved: (value) => _miaraUnit = value,
    );
  }

  Widget _buildNullableTextFormField({
    required String? initialValue,
    required String labelText,
    required Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue ?? '',
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      onSaved: (value) => onSaved(value?.isEmpty == true ? null : value),
    );
  }

  Widget _buildTextFormField({
    required String initialValue,
    required String labelText,
    required Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
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
                    _sklep = selection;
                    shopNotifier.value = selection;
                  });
                },
                onClear: () {
                  setState(() {
                    _sklep = '';
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
                    _kategoria = selection;
                    categoryNotifier.value = selection;
                  });
                },
                onClear: () {
                  setState(() {
                    _kategoria = '';
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
                    _produkt = selection;
                    productNotifier.value = selection;
                  });
                },
                onClear: () {
                  setState(() {
                    _produkt = '';
                    productNotifier.value = '';
                  });
                },
              ),
              _buildTextFormField(
                initialValue: _ilosc.toString(),
                labelText: 'Ilość',
                keyboardType: TextInputType.number,
                onSaved: (value) => _ilosc = int.parse(value ?? '1'),
              ),
              _buildTextFormField(
                initialValue: _cena.toString(),
                labelText: 'Cena',
                keyboardType: TextInputType.number,
                onSaved: (value) => _cena = double.parse(_calculatePrice(value ?? '0.0')),
              ),
              _buildNullableTextFormField(
                initialValue: _miara?.toString(),
                labelText: 'Miara',
                keyboardType: TextInputType.number,
                onSaved: (value) => _miara = value != null ? int.parse(value) : null,
              ),
              _buildDropdownButtonFormField(),
              _buildNullableTextFormField(
                initialValue: _iloscWOpakowaniu?.toString(),
                labelText: 'Ilość w opakowaniu',
                keyboardType: TextInputType.number,
                onSaved: (value) => _iloscWOpakowaniu = value != null ? int.parse(value) : null,
              ),
              _buildNullableTextFormField(
                initialValue: _kosztDostawy?.toString(),
                labelText: 'Koszt dostawy',
                keyboardType: TextInputType.number,
                onSaved: (value) => _kosztDostawy = value != null ? double.parse(value) : null,
              ),
              Row(
                children: [
                  const Text('Zwrot'),
                  Checkbox(
                    value: _zwrot,
                    onChanged: (value) {
                      setState(() {
                        _zwrot = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              _buildTextFormField(
                initialValue: _link,
                labelText: 'Link',
                onSaved: (value) => _link = value ?? '',
              ),
              _buildTextFormField(
                initialValue: _komentarz,
                labelText: 'Komentarz',
                onSaved: (value) => _komentarz = value ?? '',
              ),
              ElevatedButton(
                onPressed: _saveExpense,
                child: const Text('Zapisz'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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