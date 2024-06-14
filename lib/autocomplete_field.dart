import 'package:flutter/material.dart';

class AutocompleteField extends StatelessWidget {
  final List<String> options;
  final String label;
  final ValueNotifier<String> valueNotifier;
  final Function(String) onSelected;
  final VoidCallback onClear;

  const AutocompleteField({
    super.key,
    required this.options,
    required this.label,
    required this.valueNotifier,
    required this.onSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return options.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: onSelected,
          initialValue: TextEditingValue(text: value),
          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            fieldTextEditingController.text = value;
            fieldTextEditingController.addListener(() {
              valueNotifier.value = fieldTextEditingController.text;
            });
            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: label,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    fieldTextEditingController.clear();
                    valueNotifier.value = '';
                    FocusScope.of(context).requestFocus(FocusNode()); // Hide the keyboard
                    onClear();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}