import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final Function(BuildContext) onLoadCSV;
  final Function(BuildContext) onExportAllData;
  final Function(BuildContext) onExportFilteredData;

  const AppDrawer({
    super.key,
    required this.onLoadCSV,
    required this.onExportAllData,
    required this.onExportFilteredData,
  });

  @override
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  bool _isExportExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Importuj dane'),
            onTap: () {
              Navigator.pop(context);
              widget.onLoadCSV(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Eksportuj dane'),
            onTap: () {
              setState(() {
                _isExportExpanded = !_isExportExpanded;
              });
            },
          ),
          if (_isExportExpanded) ..._buildExportOptions(context),
        ],
      ),
    );
  }

  List<Widget> _buildExportOptions(BuildContext context) {
    return [
      ListTile(
        leading: const SizedBox(width: 35), 
        title: const Text('Wszystkie dane'),
        onTap: () {
          Navigator.pop(context);
          widget.onExportAllData(context);
        },
      ),
      ListTile(
        leading: const SizedBox(width: 35), 
        title: const Text('Tylko przefiltrowane dane'),
        onTap: () {
          Navigator.pop(context);
          widget.onExportFilteredData(context);
        },
      ),
    ];
  }
}