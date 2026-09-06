import '../../db/database_helper.dart';
import '../models/quotation_model.dart';

class QuotationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<QuotationModel>> fetchQuotations({
    String? searchQuery,
  }) async {
    return await _dbHelper.getAllQuotations(
      searchQuery: searchQuery,
    );
  }

  Future<QuotationModel?> getQuotation(int id) async {
    return await _dbHelper.getQuotationById(id);
  }

  Future<int> addQuotation(QuotationModel quotation) async {
    return await _dbHelper.insertQuotation(quotation);
  }

  Future<int> updateQuotation(QuotationModel quotation) async {
    return await _dbHelper.updateQuotation(quotation);
  }

  Future<int> deleteQuotation(int id) async {
    return await _dbHelper.deleteQuotation(id);
  }

  Future<String> generateNextNumber() async {
    return await _dbHelper.generateQuotationNumber();
  }

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    return await _dbHelper.getDashboardStats();
  }
}
