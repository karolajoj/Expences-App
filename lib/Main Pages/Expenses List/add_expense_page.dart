import '../../Repositories/Local Data/expenses_list_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadSuggestions();
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

    shopNotifier = ValueNotifier(_sklep);
    categoryNotifier = ValueNotifier(_kategoria);
    productNotifier = ValueNotifier(_produkt);
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
      await _saveExpenseToFirebase(newExpense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.expense == null ? 'Wydatek dodany pomyślnie' : 'Wydatek zaktualizowany pomyślnie')));
        Navigator.pop(context);
      }
    }
  }


  Future<void> _saveExpenseToFirebase(ExpensesListElementModel expense) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nie zalogowano użytkownika');
    }

    final newExpense = expense.copyWith(firebaseId: expense.firebaseId ?? FirebaseFirestore.instance.collection('dummy').doc().id);
    
    await FirebaseFirestore.instance
        .collection("MainCollection")
        .doc(user.uid)
        .collection("expenses")
        .doc(newExpense.firebaseId)
        .set(newExpense.toMap());
  }


  Future<void> _saveExpenseLocally(ExpensesListElementModel expense) async {
    var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
    await box.put(expense.localId, expense);
  }

  @override
  void dispose() {
    shopNotifier.dispose();
    categoryNotifier.dispose();
    productNotifier.dispose();
    super.dispose();
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
              TextFormField(
                initialValue: DateFormat('dd.MM.yyyy').format(_data),
                decoration: const InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _data) {
                    setState(() {
                      _data = picked;
                    });
                  }
                },
              ),
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
              TextFormField(
                initialValue: _ilosc.toString(),
                decoration: const InputDecoration(labelText: 'Ilość'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _ilosc = int.parse(value ?? '1'),
              ),
              TextFormField(
                initialValue: _cena.toString(),
                decoration: const InputDecoration(labelText: 'Cena'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cena = double.parse(value ?? '0.0'),
              ),
              TextFormField(
                initialValue: _miara?.toString(),
                decoration: const InputDecoration(labelText: 'Miara'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _miara = int.parse(value ?? '1'),
              ),
              TextFormField(
                initialValue: _miaraUnit ?? '',
                decoration: const InputDecoration(labelText: 'Jednostka miary'),
                onSaved: (value) => _miaraUnit = value,
              ),
              TextFormField(
                initialValue: _iloscWOpakowaniu?.toString(),
                decoration: const InputDecoration(labelText: 'Ilość w opakowaniu'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _iloscWOpakowaniu = int.parse(value ?? '1'),
              ),
              TextFormField(
                initialValue: _kosztDostawy?.toString(),
                decoration: const InputDecoration(labelText: 'Koszt dostawy'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _kosztDostawy = double.parse(value ?? '0.0'),
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
              TextFormField(
                initialValue: _link,
                decoration: const InputDecoration(labelText: 'Link'),
                onSaved: (value) => _link = value ?? '',
              ),
              TextFormField(
                initialValue: _komentarz,
                decoration: const InputDecoration(labelText: 'Komentarz'),
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