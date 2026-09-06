import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/client_model.dart';
import '../data/models/item_model.dart';
import '../data/models/quotation_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('penawaran.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // Clients table
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        email TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Quotations table
    await db.execute('''
      CREATE TABLE quotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotation_number TEXT NOT NULL UNIQUE,
        client_id INTEGER,
        client_name TEXT NOT NULL,
        client_phone TEXT NOT NULL,
        client_address TEXT NOT NULL,
        client_email TEXT,
        discount_percent REAL NOT NULL DEFAULT 0.0,
        tax_percent REAL NOT NULL DEFAULT 11.0,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'draft',
        created_at TEXT NOT NULL
      )
    ''');

    // Quotation Items table
    await db.execute('''
      CREATE TABLE quotation_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotation_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        unit TEXT NOT NULL,
        qty REAL NOT NULL,
        unit_price REAL NOT NULL,
        FOREIGN KEY (quotation_id) REFERENCES quotations (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CLIENT CRUD ---

  Future<int> insertClient(ClientModel client) async {
    final db = await instance.database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<ClientModel>> getAllClients({String? searchQuery}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      result = await db.query(
        'clients',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
        orderBy: 'created_at DESC',
      );
    } else {
      result = await db.query('clients', orderBy: 'created_at DESC');
    }
    return result.map((json) => ClientModel.fromMap(json)).toList();
  }

  Future<ClientModel?> getClientById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ClientModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateClient(ClientModel client) async {
    final db = await instance.database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await instance.database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- QUOTATION CRUD ---

  Future<int> insertQuotation(QuotationModel quotation) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final quotationId = await txn.insert('quotations', quotation.toMap());

      for (var item in quotation.items) {
        final itemMap = item.copyWith(quotationId: quotationId).toMap();
        await txn.insert('quotation_items', itemMap);
      }

      return quotationId;
    });
  }

  Future<List<QuotationModel>> getAllQuotations({
    String? searchQuery,
    String? statusFilter,
  }) async {
    final db = await instance.database;
    String? whereClause;
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause = '(client_name LIKE ? OR quotation_number LIKE ?)';
      whereArgs.addAll(['%$searchQuery%', '%$searchQuery%']);
    }

    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
      if (whereClause != null) {
        whereClause += ' AND status = ?';
      } else {
        whereClause = 'status = ?';
      }
      whereArgs.add(statusFilter);
    }

    final result = await db.query(
      'quotations',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );

    List<QuotationModel> quotations = [];
    for (var map in result) {
      final qId = map['id'] as int;
      final itemMaps = await db.query(
        'quotation_items',
        where: 'quotation_id = ?',
        whereArgs: [qId],
      );
      final items = itemMaps.map((i) => ItemModel.fromMap(i)).toList();
      quotations.add(QuotationModel.fromMap(map, items));
    }

    return quotations;
  }

  Future<QuotationModel?> getQuotationById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'quotations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final itemMaps = await db.query(
      'quotation_items',
      where: 'quotation_id = ?',
      whereArgs: [id],
    );

    final items = itemMaps.map((i) => ItemModel.fromMap(i)).toList();
    return QuotationModel.fromMap(maps.first, items);
  }

  Future<int> updateQuotation(QuotationModel quotation) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      await txn.update(
        'quotations',
        quotation.toMap(),
        where: 'id = ?',
        whereArgs: [quotation.id],
      );

      // Delete old items and insert updated items
      await txn.delete(
        'quotation_items',
        where: 'quotation_id = ?',
        whereArgs: [quotation.id],
      );

      for (var item in quotation.items) {
        final itemMap = item.copyWith(quotationId: quotation.id).toMap();
        await txn.insert('quotation_items', itemMap);
      }

      return quotation.id!;
    });
  }

  Future<int> updateQuotationStatus(int quotationId, String newStatus) async {
    final db = await instance.database;
    return await db.update(
      'quotations',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [quotationId],
    );
  }

  Future<int> deleteQuotation(int id) async {
    final db = await instance.database;
    return await db.delete(
      'quotations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> generateQuotationNumber() async {
    final db = await instance.database;
    final year = DateTime.now().year.toString();
    final countResult = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM quotations WHERE quotation_number LIKE ?', ['PNW/$year/%']),
    );
    final nextNumber = (countResult ?? 0) + 1;
    final paddedIndex = nextNumber.toString().padLeft(3, '0');
    return 'PNW/$year/$paddedIndex';
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await instance.database;
    final now = DateTime.now();
    final currentMonthPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final quotationsThisMonth = await db.rawQuery(
      'SELECT * FROM quotations WHERE created_at LIKE ?',
      ['$currentMonthPrefix%'],
    );

    double totalValueMonth = 0.0;
    for (var q in quotationsThisMonth) {
      final qId = q['id'] as int;
      final itemMaps = await db.query('quotation_items', where: 'quotation_id = ?', whereArgs: [qId]);
      final items = itemMaps.map((i) => ItemModel.fromMap(i)).toList();
      final model = QuotationModel.fromMap(q, items);
      totalValueMonth += model.grandTotal;
    }

    final totalCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM quotations')) ?? 0;
    final draftCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM quotations WHERE status = ?', ['draft'])) ?? 0;
    final approvedCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM quotations WHERE status = ?', ['approved'])) ?? 0;

    return {
      'monthCount': quotationsThisMonth.length,
      'monthValue': totalValueMonth,
      'totalCount': totalCount,
      'draftCount': draftCount,
      'approvedCount': approvedCount,
    };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
