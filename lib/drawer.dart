import 'package:expenses_app_project/Authentication/auth_page.dart';
import 'package:expenses_app_project/Authentication/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final Function(BuildContext) onLoadCSV;
  final Function(BuildContext) onReplaceCSV;
  final Function(BuildContext) onExportAllData;
  final Function(BuildContext) onExportFilteredData;
  final Function(BuildContext) onDeleteAllData;
  final Function(BuildContext) onDeleteFilteredData;

  const AppDrawer({
    super.key,
    required this.onLoadCSV,
    required this.onReplaceCSV,
    required this.onExportAllData,
    required this.onExportFilteredData,
    required this.onDeleteAllData,
    required this.onDeleteFilteredData,
  });

  @override
  AppDrawerState createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  bool _isExportExpanded = false;
  bool _isImportExpanded = false;
  bool _isDeleteExpanded = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            accountName: Text(user != null ? user?.displayName ?? 'Użytkownik' : 'Gość'),
            accountEmail: Text(user != null ? user?.email ?? '' : ''),
            currentAccountPicture: CircleAvatar(
              child: user != null && user?.photoURL != null
                  ? Image.network(user!.photoURL!)
                  : const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(user != null ? 'Wyloguj' : 'Zaloguj'),
            onTap: () async {
              Navigator.pop(context);
              if (user != null) {
                await AuthService().signout(context: context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const AuthPage(mode: AuthMode.login),
                  ),
                );
              }
              setState(() {});
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Importuj dane'),
            onTap: () {
              setState(() {
                _isImportExpanded = !_isImportExpanded;
              });
            },
          ),
          if (_isImportExpanded) ..._buildImportOptions(context),
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
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Usuń dane'),
            onTap: () {
              setState(() {
                _isDeleteExpanded = !_isDeleteExpanded;
              });
            },
          ),
          if (_isDeleteExpanded) ..._buildDeleteOptions(context),
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

  List<Widget> _buildImportOptions(BuildContext context) {
    return [
      ListTile(
        leading: const SizedBox(width: 35),
        title: const Text('Zastąp obecne dane'),
        onTap: () {
          Navigator.pop(context);
          widget.onReplaceCSV(context);
        },
      ),
      ListTile(
        leading: const SizedBox(width: 35),
        title: const Text('Dodaj nowe dane'),
        onTap: () {
          Navigator.pop(context);
          widget.onLoadCSV(context);
        },
      ),
    ];
  }

  List<Widget> _buildDeleteOptions(BuildContext context) {
    return [
      ListTile(
        leading: const SizedBox(width: 35),
        title: const Text('Wszystkie dane'),
        onTap: () {
          Navigator.pop(context);
          widget.onDeleteAllData(context);
        },
      ),
      ListTile(
        leading: const SizedBox(width: 35),
        title: const Text('Tylko przefiltrowane dane'),
        onTap: () {
          Navigator.pop(context);
          widget.onDeleteFilteredData(context);
        },
      ),
    ];
  }
}