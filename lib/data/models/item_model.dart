class ItemModel {
  final int? id;
  final int? quotationId;
  final String description;
  final String unit;
  final double qty;
  final double unitPrice;

  ItemModel({
    this.id,
    this.quotationId,
    required this.description,
    required this.unit,
    required this.qty,
    required this.unitPrice,
  });

  double get total => qty * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quotation_id': quotationId,
      'description': description,
      'unit': unit,
      'qty': qty,
      'unit_price': unitPrice,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int?,
      quotationId: map['quotation_id'] as int?,
      description: map['description'] as String? ?? '',
      unit: map['unit'] as String? ?? 'unit',
      qty: (map['qty'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ItemModel copyWith({
    int? id,
    int? quotationId,
    String? description,
    String? unit,
    double? qty,
    double? unitPrice,
  }) {
    return ItemModel(
      id: id ?? this.id,
      quotationId: quotationId ?? this.quotationId,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
