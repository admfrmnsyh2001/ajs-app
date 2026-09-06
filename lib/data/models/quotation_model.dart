import 'client_model.dart';
import 'item_model.dart';

class QuotationModel {
  final int? id;
  final String quotationNumber;
  final ClientModel client;
  final List<ItemModel> items;
  final double discountPercent;
  final double taxPercent;
  final String? notes;
  final String status;
  final DateTime createdAt;

  QuotationModel({
    this.id,
    required this.quotationNumber,
    required this.client,
    required this.items,
    this.discountPercent = 0.0,
    this.taxPercent = 11.0,
    this.notes,
    this.status = 'draft',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.total);
  double get discountAmount => subtotal * (discountPercent / 100.0);
  double get taxAmount => (subtotal - discountAmount) * (taxPercent / 100.0);
  double get grandTotal => subtotal - discountAmount + taxAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quotation_number': quotationNumber,
      'client_id': client.id,
      'client_name': client.name,
      'client_phone': client.phone,
      'client_address': client.address,
      'client_email': client.email,
      'discount_percent': discountPercent,
      'tax_percent': taxPercent,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuotationModel.fromMap(Map<String, dynamic> map, List<ItemModel> items) {
    final client = ClientModel(
      id: map['client_id'] as int?,
      name: map['client_name'] as String? ?? '',
      phone: map['client_phone'] as String? ?? '',
      address: map['client_address'] as String? ?? '',
      email: map['client_email'] as String?,
    );

    return QuotationModel(
      id: map['id'] as int?,
      quotationNumber: map['quotation_number'] as String? ?? '',
      client: client,
      items: items,
      discountPercent: (map['discount_percent'] as num?)?.toDouble() ?? 0.0,
      taxPercent: (map['tax_percent'] as num?)?.toDouble() ?? 11.0,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'draft',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  QuotationModel copyWith({
    int? id,
    String? quotationNumber,
    ClientModel? client,
    List<ItemModel>? items,
    double? discountPercent,
    double? taxPercent,
    String? notes,
    String? status,
    DateTime? createdAt,
  }) {
    return QuotationModel(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      client: client ?? this.client,
      items: items ?? this.items,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
