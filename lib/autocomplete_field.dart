import 'package:flutter/material.dart';

class AutocompleteField extends StatefulWidget {
  final List<String> options; // Lista opcji do wyświetlenia w podpowiedziach autouzupełniania.
  final String label; // Etykieta pola tekstowego.
  final ValueNotifier<String> valueNotifier; // Obiekt ValueNotifier przechowujący aktualną wartość pola tekstowego.
  final Function(String) onSelected; // Funkcja wywoływana po wybraniu opcji z listy podpowiedzi.
  final VoidCallback onClear; // Funkcja wywoływana po wyczyszczeniu pola tekstowego.

  const AutocompleteField({
    super.key,
    required this.options,
    required this.label,
    required this.valueNotifier,
    required this.onSelected,
    required this.onClear,
  });

  @override
  AutocompleteFieldState createState() => AutocompleteFieldState();
}

class AutocompleteFieldState extends State<AutocompleteField> {
  late TextEditingController fieldTextEditingController; // Kontroler tekstu dla pola tekstowego.

  @override
  void initState() {
    super.initState();
    // Inicjalizuje kontroler tekstu i ustawia jego początkowy tekst na wartość z valueNotifier.
    fieldTextEditingController = TextEditingController(text: widget.valueNotifier.value);

    // Listener kontrolera tekstu, który aktualizuje valueNotifier, gdy zmienia się tekst w polu.
    fieldTextEditingController.addListener(() {
      if (fieldTextEditingController.text != widget.valueNotifier.value) {
        widget.valueNotifier.value = fieldTextEditingController.text;
      }
    });

    // Listener valueNotifier, który aktualizuje tekst w kontrolerze tekstu, gdy zmienia się wartość valueNotifier.
    widget.valueNotifier.addListener(() {
      if (fieldTextEditingController.text != widget.valueNotifier.value) {
        fieldTextEditingController.text = widget.valueNotifier.value;
      }
    });
  }

  @override
  void dispose() {
    // Zwalnia zasoby kontrolera tekstu.
    fieldTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.valueNotifier, // Nasłuchuje zmian wartości w valueNotifier.
      builder: (context, value, child) {
        // Aktualizuje tekst w kontrolerze tekstu, jeśli jest inny niż wartość valueNotifier.
        if (fieldTextEditingController.text != value) {
          fieldTextEditingController.text = value;
        }
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            // Buduje listę opcji na podstawie wpisanego tekstu.
            return widget.options.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            // Wywołuje się po wybraniu opcji z listy, aktualizując valueNotifier i wywołując onSelected.
            widget.onSelected(selection);
            widget.valueNotifier.value = selection;
          },
          initialValue: TextEditingValue(text: value), // Ustawia początkową wartość pola tekstowego.
          fieldViewBuilder: (BuildContext context, TextEditingController localTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            localTextEditingController.text = value; // Ustawia początkowy tekst w lokalnym kontrolerze tekstu.
            localTextEditingController.addListener(() {
              // Listener lokalnego kontrolera tekstu, który aktualizuje valueNotifier, gdy zmienia się tekst w polu.
              if (localTextEditingController.text != widget.valueNotifier.value) {
                widget.valueNotifier.value = localTextEditingController.text;
              }
            });
            return TextFormField(
              controller: localTextEditingController, // Ustawia kontroler tekstu dla TextFormField.
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: widget.label, // Ustawia etykietę pola tekstowego.
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Wywołuje się po kliknięciu ikony wyczyszczenia, czyszcząc pole tekstowe i aktualizując valueNotifier.
                    localTextEditingController.clear();
                    widget.valueNotifier.value = '';
                    FocusScope.of(context).requestFocus(FocusNode()); // Ukrywa klawiaturę po wyczyszczeniu pola.
                    widget.onClear();
                  },
                ),
              ),
              onFieldSubmitted: (String value) {
                // Wywołuje się po zatwierdzeniu tekstu, aktualizując valueNotifier.
                widget.valueNotifier.value = value;
              },
            );
          },
          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
            final int optionCount = options.length;
            const double optionHeight = 56.0; // Domyślna wysokość ListTile.

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: optionCount <= 4 ? optionHeight * optionCount : optionHeight * 4, // Ogranicza maksymalną wysokość listy opcji.
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40, // Dopasowuje szerokość do szerokości TextFormField.
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: optionCount,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          tileColor: index == 0 ? Colors.grey[200] : Colors.white,
                          onTap: () {
                            // Wywołuje się po kliknięciu opcji, aktualizując valueNotifier i wywołując onSelected.
                            onSelected(option);
                            widget.onSelected(option);
                            widget.valueNotifier.value = option;
                          },
                          hoverColor: Colors.grey[500],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}