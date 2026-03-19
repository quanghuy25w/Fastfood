import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = context.read<AuthProvider>();

      // Load lại thông tin user từ database
      await authProvider.loadCurrentUser();

      if (!mounted) return;

      // Nếu user đã login, load cart và orders
      if (authProvider.currentUser?.id != null) {
        final userId = authProvider.currentUser!.id!;
        final cartProvider = context.read<CartProvider>();
        final orderProvider = context.read<OrderProvider>();

        await cartProvider.loadCart(userId);
        await orderProvider.fetchOrders(userId);
      }

      if (!mounted) return;

      // Navigate tới screen phù hợp dựa trên role
      String? route;
      if (authProvider.currentUser != null) {
        if (authProvider.currentUser!.isAdmin) {
          route = AppRoutes.adminDashboard;
        } else {
          route = AppRoutes.dashboard;
        }
      } else {
        route = AppRoutes.login;
      }

      Navigator.of(context).pushReplacementNamed(route);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
