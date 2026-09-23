import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_chrome.dart';
import 'directory_screen.dart';
import 'birthdays_screen.dart';
import 'overview_screen.dart';
import 'form_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleTab(int index) {
    if (index == 3) {
      _openAdd();
    } else {
      _switchTab(index);
    }
  }

  void _openAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopRow(),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    DirectoryScreen(
                      onSwitchTab: _switchTab,
                      onOpenAdd: _openAdd,
                    ),
                    const BirthdaysScreen(),
                    const OverviewScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CircleTabBar(
        currentIndex: _currentIndex,
        onSelect: _handleTab,
      ),
    );
  }
}

class _CircleTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _CircleTabBar({required this.currentIndex, required this.onSelect});

  static const _tabs = ['Directory', 'Birthdays', 'Overview', 'Add'];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      key: const Key('circle-tab-bar'),
      height: 64,
      decoration: BoxDecoration(
        color: tokens.tabbar,
        border: Border(top: BorderSide(color: tokens.border, width: 1)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Row(
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final isAdd = index == 3;
              final active = !isAdd && index == currentIndex;
              final color = active ? tokens.accent : tokens.tabInactive;

              return Expanded(
                child: GestureDetector(
                  key: Key('tab-${label.toLowerCase()}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        key: Key('tab-dot-${label.toLowerCase()}'),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: active ? tokens.accent : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
