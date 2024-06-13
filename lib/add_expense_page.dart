import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'Repositories/Local Data/expenses_list_element.dart';

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
  List<String> _allSklepy = [];
  List<String> _allKategorie = [];
  List<String> _allProdukty = [];

  @override
  void initState() {
    super.initState();
    loadAllSuggestions();
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
  }

  Future<void> loadAllSuggestions() async {
    var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
    var allExpenses = box.values.toList();
    setState(() {
      _allSklepy = allExpenses.map((expense) => expense.sklep.trim()).where((sklep) => sklep.isNotEmpty).toSet().toList()..sort();
      _allKategorie = allExpenses.map((expense) => expense.kategoria.trim()).where((kategoria) => kategoria.isNotEmpty).toSet().toList()..sort();
      _allProdukty = allExpenses.map((expense) => expense.produkt.trim()).where((produkt) => produkt.isNotEmpty).toSet().toList()..sort();
    });
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.expense == null ? 'Wydatek dodany pomyślnie' : 'Wydatek zaktualizowany pomyślnie')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Dodaj wydatek' : 'Edytuj wydatek'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }                  
                  return _allSklepy.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  setState(() {
                    _sklep = selection;
                  });
                },
                fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Sklep',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          fieldTextEditingController.clear();
                        },
                      ),
                    ),
                    onSaved: (value) => _sklep = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pole sklep nie może być puste';
                      }
                      return null;
                    },
                    onTap: () {
                      setState(() {
                        fieldTextEditingController.text = '';
                      });
                    },
                  );
                },
              ),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }                  
                  return _allKategorie.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  setState(() {
                    _kategoria = selection;
                  });
                },
                fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Kategoria',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          fieldTextEditingController.clear();
                        },
                      ),
                    ),
                    onSaved: (value) => _kategoria = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pole kategoria nie może być puste';
                      }
                      return null;
                    },
                    onTap: () {
                      setState(() {
                        fieldTextEditingController.text = '';
                      });
                    },
                  );
                },
              ),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _allProdukty.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  setState(() {
                    _produkt = selection;
                  });
                },
                fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Produkt',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          fieldTextEditingController.clear();
                        },
                      ),
                    ),
                    onSaved: (value) => _produkt = value!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pole produkt nie może być puste';
                      }
                      return null;
                    },
                    onTap: () {
                      setState(() {
                        fieldTextEditingController.text = '';
                      });
                    },                    
                  );
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