import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(BuildContext) onLoadCSV;
  final Function(BuildContext) onExportCSV;

  const AppDrawer({super.key, required this.onLoadCSV, required this.onExportCSV});

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
              onLoadCSV(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Eksportuj dane'),
            onTap: () {
              Navigator.pop(context);
              onExportCSV(context);
            },
          ),
        ],
      ),
    );
  }
}