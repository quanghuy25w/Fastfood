import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'data/database/database_helper.dart';
import 'providers/address_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'services/shared_prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPrefsService.instance;
  final isDarkMode = await prefs.getDarkMode();
  final isLoggedIn = await prefs.getLoggedIn();
  final userId = await prefs.getUserId();

  // Ensure SQLite is initialized before app starts.
  await DatabaseHelper().database;

  runApp(
    FastFoodApp(
      initialIsDarkMode: isDarkMode,
      initialIsLoggedIn: isLoggedIn,
      initialUserId: userId,
    ),
  );
}

class FastFoodApp extends StatefulWidget {
  const FastFoodApp({
    super.key,
    this.initialIsDarkMode = false,
    this.initialIsLoggedIn = false,
    this.initialUserId,
  });

  final bool initialIsDarkMode;
  final bool initialIsLoggedIn;
  final int? initialUserId;

  @override
  State<FastFoodApp> createState() => _FastFoodAppState();
}

class _FastFoodAppState extends State<FastFoodApp> {
  late final AuthProvider _authProvider;
  late final ProductProvider _productProvider;
  late final CartProvider _cartProvider;
  late final OrderProvider _orderProvider;
  late final AddressProvider _addressProvider;
  late final ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();

    _authProvider = AuthProvider();
    _productProvider = ProductProvider();
    _cartProvider = CartProvider();
    _orderProvider = OrderProvider();
    _addressProvider = AddressProvider();
    _themeProvider = ThemeProvider(isDarkMode: widget.initialIsDarkMode);

    _addressProvider.fetchAddresses();

    if (widget.initialIsLoggedIn) {
      _authProvider.loadCurrentUser();
    }

    if (widget.initialUserId != null) {
      _cartProvider.loadCart(widget.initialUserId!);
      _orderProvider.fetchOrders(widget.initialUserId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<ProductProvider>.value(value: _productProvider),
        ChangeNotifierProvider<CartProvider>.value(value: _cartProvider),
        ChangeNotifierProvider<OrderProvider>.value(value: _orderProvider),
        ChangeNotifierProvider<AddressProvider>.value(value: _addressProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'FastFood',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: AppRoutes.initialRoute(
              isLoggedIn: widget.initialIsLoggedIn,
            ),
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
