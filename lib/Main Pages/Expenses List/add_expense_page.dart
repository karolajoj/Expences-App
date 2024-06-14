import '../../Repositories/Local Data/expenses_list_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../autocomplete_field.dart';
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

      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }

      final newExpense = ExpensesListElementModel(
        id: widget.expense?.id ?? FirebaseFirestore.instance.collection('dummy').doc().id,
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

      await FirebaseFirestore.instance
          .collection("MainCollection")
          .doc(user.uid)
          .collection("expenses")
          .doc(newExpense.id)
          .set(newExpense.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.expense == null ? 'Wydatek dodany pomyślnie' : 'Wydatek zaktualizowany pomyślnie')));
        Navigator.pop(context);
      }
    }
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
              // ... inne pola formularza
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