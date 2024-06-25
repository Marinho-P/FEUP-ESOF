import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterMenu extends StatefulWidget {
  final ValueChanged<String> onChangedFilter;
  const FilterMenu({super.key, required this.onChangedFilter});

  @override
  FilterMenuState createState() => FilterMenuState();
}

class FilterMenuState extends State<FilterMenu> {
  String selectedFilter = 'None'; // Initial filter selection


  void updateFilter(String filter) {
    setState(() {
      if (selectedFilter == filter) {
        // If the same filter is clicked again, unselect it
        selectedFilter = 'None';
      } else {
        selectedFilter = filter;
      }
    });
    widget.onChangedFilter(selectedFilter); // Update with the new filter state
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentMode = themeProvider.seeMode();
    Color backColor;
    if(currentMode == 'light'){
      backColor = Colors.white;
    }else {
      backColor = Theme.of(context).colorScheme.secondary;
    }
    return PopupMenuButton(
      icon: const Icon(Icons.filter_list),
      color: backColor,
      tooltip: 'Filter Events',
      offset: const Offset(0.0, 70),
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          checked: selectedFilter == 'Nearest',
          value: 'Nearest',
          child: ListTile(
            onTap: () => updateFilter('Nearest'),
            leading: Icon(Icons.gps_fixed, color: selectedFilter == 'Nearest' ? Colors.green : null), // Color can change
            title: const Text("Nearest"),
          ),
        ),
        CheckedPopupMenuItem(
          checked: selectedFilter == 'Upcoming',
          value: 'Upcoming',
          child: ListTile(
            onTap: () => updateFilter('Upcoming'),
            leading: Icon(Icons.access_time_filled, color: selectedFilter == 'Upcoming' ? Colors.green : null), // Color can change
            title: const Text("Upcoming"),
          ),
        ),
      ],
      onSelected: (value) {
        updateFilter(value);
            },
    );
  }
}