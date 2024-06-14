import 'package:flutter/material.dart';

class AutocompleteField extends StatelessWidget {
  final List<String> options;
  final String label;
  final TextEditingController controller;
  final Function(String) onSelected;

  const AutocompleteField({
    super.key,
    required this.options,
    required this.label,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
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
      fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                fieldTextEditingController.clear();
                FocusScope.of(context).requestFocus(FocusNode()); // Hide the keyboard
              },
            ),
          ),
          onSaved: (value) => controller.text = value!,
          onTap: () {
            fieldTextEditingController.text = '';
          },
        );
      },
    );
  }
}