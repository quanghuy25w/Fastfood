import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/order/order_detail_screen.dart';
import '../../features/order/order_history_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/product/product_list_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String productList = '/products';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String settings = '/settings';

  static String initialRoute({required bool isLoggedIn}) {
    return isLoggedIn ? dashboard : login;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settingsArg) {
    switch (settingsArg.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case productList:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case productDetail:
        final product = settingsArg.arguments;
        if (product is Product) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          );
        }
        return _unknownRoute('Missing product argument');
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case orderDetail:
        final orderId = settingsArg.arguments;
        if (orderId is int) {
          return MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId),
          );
        }
        return _unknownRoute('Missing orderId argument');
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return _unknownRoute('Route not found: ${settingsArg.name}');
    }
  }

  static Route<dynamic> _unknownRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Route Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
