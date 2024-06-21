import 'package:flutter/material.dart';
import 'Filters/filter_utils.dart';

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
  late TextEditingController fieldTextEditingController;

  @override
  void initState() {
    super.initState();
    fieldTextEditingController = TextEditingController(text: widget.valueNotifier.value);

    fieldTextEditingController.addListener(() {
      if (fieldTextEditingController.text != widget.valueNotifier.value) {
        widget.valueNotifier.value = fieldTextEditingController.text;
      }
    });

    widget.valueNotifier.addListener(() {
      if (fieldTextEditingController.text != widget.valueNotifier.value) {
        fieldTextEditingController.text = widget.valueNotifier.value;
      }
    });
  }

  @override
  void dispose() {
    fieldTextEditingController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.valueNotifier,
      builder: (context, value, child) {
        if (fieldTextEditingController.text != value) {
          fieldTextEditingController.text = value;
        }
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            String normalizedInput = removeDiacritics(textEditingValue.text.toLowerCase());
            return widget.options.where((String option) {
              String normalizedOption = removeDiacritics(option.toLowerCase());
              return normalizedOption.contains(normalizedInput);
            });
          },
          onSelected: (String selection) {
            widget.onSelected(selection);
            widget.valueNotifier.value = selection;
          },
          initialValue: TextEditingValue(text: value),
          fieldViewBuilder: (BuildContext context, TextEditingController localTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            localTextEditingController.text = value;
            localTextEditingController.addListener(() {
              if (localTextEditingController.text != widget.valueNotifier.value) {
                widget.valueNotifier.value = localTextEditingController.text;
              }
            });
            return TextFormField(
              controller: localTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    localTextEditingController.clear();
                    widget.valueNotifier.value = '';
                    FocusScope.of(context).requestFocus(FocusNode());
                    widget.onClear();
                  },
                ),
              ),
              onFieldSubmitted: (String value) {
                widget.valueNotifier.value = value;
              },
            );
          },
          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
            final int optionCount = options.length;
            const double optionHeight = 56.0;

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: optionCount <= 4 ? optionHeight * optionCount : optionHeight * 4,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: optionCount,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          tileColor: index == 0 ? Colors.grey[200] : Colors.white,
                          onTap: () {
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