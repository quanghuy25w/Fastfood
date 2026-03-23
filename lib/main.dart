import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/address.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/address/address_form_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_shell.dart';
import 'theme/app_readability_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MiniShoppRoot(),
    ),
  );
}

class MiniShoppRoot extends StatefulWidget {
  const MiniShoppRoot({super.key});

  @override
  State<MiniShoppRoot> createState() => _MiniShoppRootState();
}

class _MiniShoppRootState extends State<MiniShoppRoot> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final theme = context.read<ThemeProvider>();
    final cart = context.read<CartProvider>();
    await auth.init();
    await theme.load();
    if (auth.user != null) {
      await cart.load(auth.user!.id);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppReadabilityTheme.primary,
            ),
          ),
        ),
      );
    }

    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, theme, auth, _) {
        final light = AppReadabilityTheme.light();
        final dark = AppReadabilityTheme.dark();
        return MaterialApp(
          title: 'Mini Shopp',
          debugShowCheckedModeBanner: false,
          // Tắt animation đổi theme — tránh lỗi nội suy TextStyle (inherit khác nhau giữa light/dark).
          themeAnimationDuration: Duration.zero,
          themeMode: theme.mode,
          theme: light,
          darkTheme: dark,
          home: auth.isLoggedIn
              ? (auth.isAdmin ? const AdminHomeScreen() : const MainShell())
              : const LoginScreen(),
          routes: {
            '/address-form': (context) {
              final raw = ModalRoute.of(context)?.settings.arguments;
              final parsed = raw is String ? Address.fromJson(raw) : null;
              return AddressFormScreen(
                initialAddress: parsed,
                initialStreetFallback: parsed == null && raw is String && raw.trim().isNotEmpty
                    ? raw
                    : null,
              );
            },
          },
        );
      },
    );
  }
}
