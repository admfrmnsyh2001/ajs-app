import 'package:flutter/material.dart';
import '../data/models/client_model.dart';
import '../data/models/quotation_model.dart';
import '../features/client/client_form_screen.dart';
import '../features/client/client_list_screen.dart';
import '../features/home/home_screen.dart';
import '../features/quotation/create/create_quotation_screen.dart';
import '../features/quotation/detail/quotation_detail_screen.dart';
import '../features/quotation/list/quotation_list_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String createQuotation = '/create-quotation';
  static const String quotationList = '/quotation-list';
  static const String quotationDetail = '/quotation-detail';
  static const String clientList = '/client-list';
  static const String clientForm = '/client-form';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case createQuotation:
        final qToEdit = settings.arguments as QuotationModel?;
        return MaterialPageRoute(
          builder: (_) => CreateQuotationScreen(quotationToEdit: qToEdit),
        );

      case quotationList:
        return MaterialPageRoute(builder: (_) => const QuotationListScreen());

      case quotationDetail:
        final id = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => QuotationDetailScreen(quotationId: id),
        );

      case clientList:
        return MaterialPageRoute(builder: (_) => const ClientListScreen());

      case clientForm:
        final cToEdit = settings.arguments as ClientModel?;
        return MaterialPageRoute(
          builder: (_) => ClientFormScreen(clientToEdit: cToEdit),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
