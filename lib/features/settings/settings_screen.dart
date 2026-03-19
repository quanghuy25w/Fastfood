import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../address/address_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cai dat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              value: themeProvider.isDarkMode,
              title: const Text('Dark Mode'),
              subtitle: const Text('Bat giao dien toi de nhin de hon ban dem'),
              activeColor: colors.secondary,
              onChanged: (_) {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Quan ly dia chi giao hang'),
              subtitle: const Text('Them, sua, xoa va chon dia chi mac dinh'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddressListScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
