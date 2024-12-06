import 'package:flutter/material.dart';
import '../text_styles.dart';
import 'user_management.dart';
import 'add_news.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de Administrador', style: TextStyles.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Administrar Usuarios'),
            Tab(text: 'Agregar Noticia'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UserManagement(),
          AddNews(),
        ],
      ),
    );
  }
}