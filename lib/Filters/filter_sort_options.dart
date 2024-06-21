import 'package:flutter/material.dart';
import 'filter_utils.dart';

class FilterSortOptions extends StatelessWidget {
  final SortOption sortOption;
  final bool isAscending;
  final Function(SortOption) onSortOptionChanged;
  final Function(bool) onOrderChanged;

  const FilterSortOptions({
    super.key,
    required this.sortOption,
    required this.isAscending,
    required this.onSortOptionChanged,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ChoiceChip(
          label: const Text('Data'),
          selected: sortOption == SortOption.date,
          onSelected: (selected) {
            onSortOptionChanged(SortOption.date);
          },
        ),
        ChoiceChip(
          label: const Text('Produkt'),
          selected: sortOption == SortOption.product,
          onSelected: (selected) {
            onSortOptionChanged(SortOption.product);
          },
        ),
        ChoiceChip(
          label: const Text('Koszt'),
          selected: sortOption == SortOption.cost,
          onSelected: (selected) {
            onSortOptionChanged(SortOption.cost);
          },
        ),
        IconButton(
          icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
          onPressed: () {
            onOrderChanged(!isAscending);
          },
        ),
      ],
    );
  }
}