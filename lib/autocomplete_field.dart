import 'package:flutter/material.dart';

class AutocompleteField extends StatefulWidget {
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
  AutocompleteFieldState createState() => AutocompleteFieldState();
}

class AutocompleteFieldState extends State<AutocompleteField> {
  late ValueNotifier<int> hoveredIndexNotifier;

  @override
  void initState() {
    super.initState();
    hoveredIndexNotifier = ValueNotifier<int>(-1);
  }

  @override
  void dispose() {
    hoveredIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.valueNotifier,
      builder: (context, value, child) {
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            return widget.options.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: widget.onSelected,
          initialValue: TextEditingValue(text: value),
          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            fieldTextEditingController.text = value;
            fieldTextEditingController.addListener(() {
              widget.valueNotifier.value = fieldTextEditingController.text;
            });
            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    fieldTextEditingController.clear();
                    widget.valueNotifier.value = '';
                    FocusScope.of(context).requestFocus(FocusNode()); // Hide the keyboard when the field is cleared
                    widget.onClear();
                  },
                ),
              ),
            );
          },
          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
            final List<String> allOptions = widget.options;
            final int optionCount = allOptions.length;
            const double optionHeight = 56.0; // Default height of ListTile

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: optionCount <= 4 ? optionHeight * optionCount : optionHeight * 4,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40, // Adjust to match the width of the TextField
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: optionCount,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = allOptions[index];
                        return ListTile(
                          title: Text(option),
                          tileColor: index == 0 ? Colors.grey[200] : Colors.white,
                          onTap: () {
                            onSelected(option);
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