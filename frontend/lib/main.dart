import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/prediction_page.dart';

void main() {
  runApp(const SleepWiseApp());
}

class SleepWiseApp extends StatelessWidget {
  const SleepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 1; // Start on Prediksi tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return const PredictionPage();
      default:
        return _buildPlaceholderPage(_getPageTitle(_currentIndex));
    }
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Prediksi';
      case 2:
        return 'Riwayat';
      case 3:
        return 'Statistik';
      case 4:
        return 'Model ML';
      default:
        return '';
    }
  }

  Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.surfaceBorder,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Prediksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.model_training_rounded),
            label: 'Model ML',
          ),
        ],
      ),
    );
  }
}
