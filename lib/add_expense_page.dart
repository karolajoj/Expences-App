import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'expenses_list_element.dart';

class AddExpensePage extends StatefulWidget {
  final ExpensesListElementModel expense;

  const AddExpensePage({super.key, required this.expense});

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

  @override
  void initState() {
    super.initState();
    _data = widget.expense.data;
    _sklep = widget.expense.sklep;
    _kategoria = widget.expense.kategoria;
    _produkt = widget.expense.produkt;
    _ilosc = widget.expense.ilosc;
    _cena = widget.expense.cena;
    _miara = widget.expense.miara;
    _miaraUnit = widget.expense.miaraUnit;
    _iloscWOpakowaniu = widget.expense.iloscWOpakowaniu;
    _kosztDostawy = widget.expense.kosztDostawy;
    _zwrot = widget.expense.zwrot;
    _link = widget.expense.link;
    _komentarz = widget.expense.komentarz;
    _loadExpense();
  }

  Future<void> _loadExpense() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nie zalogowano użytkownika');
    }

    final DocumentSnapshot expenseDoc = await FirebaseFirestore.instance
        .collection("MainCollection")
        .doc(user.uid)
        .collection("expenses")
        .doc(widget.expense.id)
        .get();

    final expenseData = expenseDoc.data() as Map<String, dynamic>;
    final expense = ExpensesListElementModel.fromMap(expenseData);

    setState(() {
      _data = expense.data;
      _sklep = expense.sklep;
      _kategoria = expense.kategoria;
      _produkt = expense.produkt;
      _ilosc = expense.ilosc;
      _cena = expense.cena;
      _miara = expense.miara;
      _miaraUnit = expense.miaraUnit;
      _iloscWOpakowaniu = expense.iloscWOpakowaniu;
      _kosztDostawy = expense.kosztDostawy;
      _zwrot = expense.zwrot;
      _link = expense.link;
      _komentarz = expense.komentarz;
    });
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }

      final updatedExpense = ExpensesListElementModel(
        id: widget.expense.id,
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
          .doc(widget.expense.id)
          .set(updatedExpense.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wydatek zaktualizowany pomyślnie')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj wydatek'),
      ),
      body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _sklep,
                      decoration: const InputDecoration(labelText: 'Sklep'),
                      onSaved: (value) => _sklep = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pole sklep nie może być puste';
                        }
                        return null;
                      },
                    ),
                    // Dodaj resztę pól formularza w podobny sposób
                    TextFormField(
                      initialValue: _produkt,
                      decoration: const InputDecoration(labelText: 'Produkt'),
                      onSaved: (value) => _produkt = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pole produkt nie może być puste';
                        }
                        return null;
                      },
                    ),
                    // ... inne pola formularza
                    ElevatedButton(
                      onPressed: _saveExpense,
                      child: const Text('Zapisz'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}