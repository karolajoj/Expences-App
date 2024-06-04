import 'package:expenses_app_project/authentication/Pages/auth_page.dart';
import 'package:expenses_app_project/authentication/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                  : const Icon(Icons.person , size: 50, color: Colors.white),
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