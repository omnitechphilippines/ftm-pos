class OrderModel {
  final String id;
  final List<String> code;
  final List<String> name;
  final List<double> originalPrice;
  final List<double> sellingPrice;
  final List<double> amount;
  final List<int> quantity;
  final double total;
  final DateTime orderAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({required this.id, required this.code, required this.name, required this.originalPrice, required this.sellingPrice, required this.amount, required this.quantity, required this.total, required this.orderAt, required this.createdAt, required this.updatedAt});

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    // code: json['code'],
    // name: json['name'],
    // originalPrice: json['original_price'],
    // sellingPrice: json['selling_price'],
    // amount: json['amount'],
    // quantity: json['quantity'],

    // FIX: Safely convert List<dynamic> to List<String>
    code: List<String>.from(json['code'] ?? <dynamic>[]),
    name: List<String>.from(json['name'] ?? <dynamic>[]),

    // FIX: Safely convert numeric array data to List<double>
    originalPrice: (json['original_price'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => (e as num).toDouble()).toList(),
    sellingPrice: (json['selling_price'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => (e as num).toDouble()).toList(),
    amount: (json['amount'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => (e as num).toDouble()).toList(),

    // FIX: Safely convert numbers to List<int>
    quantity: List<int>.from(json['quantity'] ?? <dynamic>[]),

    total: json['total'],
    orderAt: DateTime.parse(json['order_at']).toLocal(),
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'code': code,
    'name': name,
    'original_price': originalPrice,
    'selling_price': sellingPrice,
    'amount': amount,
    'quantity': quantity,
    'total': total,
    'order_at': orderAt.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  OrderModel copyWith({String? id, List<String>? code, List<String>? name, List<double>? originalPrice, List<double>? sellingPrice, List<double>? amount, List<int>? quantity, double? total, DateTime? orderAt, DateTime? createdAt, DateTime? updatedAt}) => OrderModel(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    originalPrice: originalPrice ?? this.originalPrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    amount: amount ?? this.amount,
    quantity: quantity ?? this.quantity,
    total: total ?? this.total,
    orderAt: orderAt ?? this.orderAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
