import 'package:flutter/material.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/item_model.dart';
import '../../../data/models/quotation_model.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/quotation_repository.dart';

class CreateQuotationProvider extends ChangeNotifier {
  final QuotationRepository _quotationRepo = QuotationRepository();
  final ClientRepository _clientRepo = ClientRepository();

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Step 1: Client Info
  ClientModel? _selectedClient;
  ClientModel? get selectedClient => _selectedClient;

  String _quotationNumber = '';
  String get quotationNumber => _quotationNumber;

  bool _isManualClient = false;
  bool get isManualClient => _isManualClient;

  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientPhoneController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientEmailController = TextEditingController();

  // Step 2: Items Info
  List<ItemModel> _items = [];
  List<ItemModel> get items => List.unmodifiable(_items);

  final TextEditingController itemDescController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  String _selectedUnit = 'm²';
  String get selectedUnit => _selectedUnit;

  int? _editingItemIndex;
  int? get editingItemIndex => _editingItemIndex;

  // Step 3: Summary Info
  double _discountPercent = 0.0;
  double get discountPercent => _discountPercent;

  double _taxPercent = 11.0; // Default PPN 11%
  double get taxPercent => _taxPercent;

  final TextEditingController notesController = TextEditingController();
  final TextEditingController discountController = TextEditingController(text: '0');
  final TextEditingController taxController = TextEditingController(text: '11');

  // Calculations
  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.total);
  double get discountAmount => subtotal * (_discountPercent / 100.0);
  double get taxAmount => (subtotal - discountAmount) * (_taxPercent / 100.0);
  double get grandTotal => subtotal - discountAmount + taxAmount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _existingQuotationId;
  int? get existingQuotationId => _existingQuotationId;

  CreateQuotationProvider() {
    initNewQuotation();
  }

  Future<void> initNewQuotation() async {
    _isLoading = true;
    notifyListeners();

    _currentStep = 0;
    _selectedClient = null;
    _isManualClient = false;
    _items = [];
    _discountPercent = 0.0;
    _taxPercent = 11.0;
    _existingQuotationId = null;
    _editingItemIndex = null;

    clientNameController.clear();
    clientPhoneController.clear();
    clientAddressController.clear();
    clientEmailController.clear();

    clearItemForm();

    notesController.clear();
    discountController.text = '0';
    taxController.text = '11';

    _quotationNumber = await _quotationRepo.generateNextNumber();

    _isLoading = false;
    notifyListeners();
  }

  void loadQuotationForEdit(QuotationModel quotation) {
    _existingQuotationId = quotation.id;
    _quotationNumber = quotation.quotationNumber;
    _selectedClient = quotation.client;
    _isManualClient = false;

    clientNameController.text = quotation.client.name;
    clientPhoneController.text = quotation.client.phone;
    clientAddressController.text = quotation.client.address;
    clientEmailController.text = quotation.client.email ?? '';

    _items = List.from(quotation.items);
    _discountPercent = quotation.discountPercent;
    _taxPercent = quotation.taxPercent;
    discountController.text = quotation.discountPercent.toString();
    taxController.text = quotation.taxPercent.toString();
    notesController.text = quotation.notes ?? '';

    _currentStep = 0;
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // --- CLIENT ACTIONS ---

  void selectClient(ClientModel client) {
    _selectedClient = client;
    _isManualClient = false;
    clientNameController.text = client.name;
    clientPhoneController.text = client.phone;
    clientAddressController.text = client.address;
    clientEmailController.text = client.email ?? '';
    notifyListeners();
  }

  void toggleManualClient(bool manual) {
    _isManualClient = manual;
    if (manual) {
      _selectedClient = null;
    }
    notifyListeners();
  }

  // --- ITEM ACTIONS ---

  void setSelectedUnit(String unit) {
    _selectedUnit = unit;
    notifyListeners();
  }

  void clearItemForm() {
    itemDescController.clear();
    itemQtyController.clear();
    itemPriceController.clear();
    _selectedUnit = 'm²';
    _editingItemIndex = null;
    notifyListeners();
  }

  void startEditingItem(int index) {
    _editingItemIndex = index;
    final item = _items[index];
    itemDescController.text = item.description;
    _selectedUnit = item.unit;
    itemQtyController.text = item.qty.toString();
    itemPriceController.text = item.unitPrice.toString();
    notifyListeners();
  }

  void addOrUpdateItem() {
    final desc = itemDescController.text.trim();
    final qty = double.tryParse(itemQtyController.text.trim()) ?? 0.0;
    final price = double.tryParse(itemPriceController.text.trim()) ?? 0.0;

    if (desc.isEmpty || qty <= 0 || price <= 0) {
      return;
    }

    final newItem = ItemModel(
      description: desc,
      unit: _selectedUnit,
      qty: qty,
      unitPrice: price,
    );

    if (_editingItemIndex != null) {
      _items[_editingItemIndex!] = newItem;
    } else {
      _items.add(newItem);
    }

    clearItemForm();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    if (_editingItemIndex == index) {
      clearItemForm();
    }
    notifyListeners();
  }

  // --- SUMMARY ACTIONS ---

  void updateDiscount(String value) {
    _discountPercent = double.tryParse(value) ?? 0.0;
    notifyListeners();
  }

  void updateTax(String value) {
    _taxPercent = double.tryParse(value) ?? 0.0;
    notifyListeners();
  }

  // --- SAVE QUOTATION ---

  Future<QuotationModel?> saveQuotation({String status = 'draft'}) async {
    final clientName = clientNameController.text.trim();
    final clientPhone = clientPhoneController.text.trim();
    final clientAddress = clientAddressController.text.trim();
    final clientEmail = clientEmailController.text.trim();

    if (clientName.isEmpty || _items.isEmpty) {
      return null;
    }

    _isLoading = true;
    notifyListeners();

    ClientModel client;
    if (_selectedClient != null && !_isManualClient) {
      client = _selectedClient!;
    } else {
      client = ClientModel(
        name: clientName,
        phone: clientPhone,
        address: clientAddress,
        email: clientEmail.isNotEmpty ? clientEmail : null,
      );
      // Auto save client to database if manual entry
      final clientId = await _clientRepo.addClient(client);
      client = client.copyWith(id: clientId);
    }

    final quotation = QuotationModel(
      id: _existingQuotationId,
      quotationNumber: _quotationNumber,
      client: client,
      items: _items,
      discountPercent: _discountPercent,
      taxPercent: _taxPercent,
      notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
      status: status,
    );

    if (_existingQuotationId != null) {
      await _quotationRepo.updateQuotation(quotation);
    } else {
      final id = await _quotationRepo.addQuotation(quotation);
      _existingQuotationId = id;
    }

    _isLoading = false;
    notifyListeners();

    return quotation.copyWith(id: _existingQuotationId);
  }
}
