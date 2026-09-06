import '../../db/database_helper.dart';
import '../models/client_model.dart';

class ClientRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ClientModel>> fetchClients({String? searchQuery}) async {
    return await _dbHelper.getAllClients(searchQuery: searchQuery);
  }

  Future<ClientModel?> getClient(int id) async {
    return await _dbHelper.getClientById(id);
  }

  Future<int> addClient(ClientModel client) async {
    return await _dbHelper.insertClient(client);
  }

  Future<int> updateClient(ClientModel client) async {
    return await _dbHelper.updateClient(client);
  }

  Future<int> deleteClient(int id) async {
    return await _dbHelper.deleteClient(id);
  }
}
