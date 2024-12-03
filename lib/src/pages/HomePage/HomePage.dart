import 'package:flutter/material.dart';
import 'tabs/FreeCoursesPage.dart';
import 'tabs/libros.dart';
import 'tabs/Principal.dart';
import 'widgets/CustomAppBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _titles = ["Inicio", "Libreria", "Cursos"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: TabBarView(
          controller: _tabController,
          children: const [
            Principal(),
            LibrosPage(),
            FreeCoursesPage(),
          ],
        ),
        bottomNavigationBar: Container(
          color: const Color(0xFF2f2c44),
          child: TabBar(
            controller: _tabController,
            tabs: List.generate(3, (index) {
              final isSelected = _tabController.index == index;
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index == 2)
                      ImageIcon(
                        AssetImage('assets/Icons/courses_icon.png'),
                        size: 24,
                        color: isSelected ? Colors.white : Colors.white54,
                      )
                    else
                      Icon(
                        [Icons.home, Icons.book, Icons.new_releases][index],
                        size: 24,
                        color: isSelected ? Colors.white : Colors.white54,
                      ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        _titles[index],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              );
            }),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicator: BoxDecoration(
              color: const Color(0xFF1c1a29),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
    );
  }
}