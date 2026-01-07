import 'dart:typed_data';
import 'dart:convert';

class ProductModel {
  final String id;
  final String code;
  final String name;
  final double originalPrice;
  final double sellingPrice;
  final int quantity;
  final String? weight;
  final DateTime? expiryDate;
  final Uint8List? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({required this.id, required this.code, required this.name, required this.originalPrice, required this.sellingPrice, required this.quantity, this.weight, this.expiryDate, this.image, required this.createdAt, required this.updatedAt});

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    code: json['code'],
    name: json['name'],
    originalPrice: json['original_price'],
    sellingPrice: json['selling_price'],
    quantity: json['quantity'],
    weight: json['weight'],
    expiryDate: DateTime.tryParse(json['expiry_date'] ?? '')?.toLocal(),
    image: Uint8List.fromList(jsonDecode(utf8.decode(_hexToUint8List(json['image'].substring(2)))).cast<int>()),
    createdAt: DateTime.parse(json['created_at']).toLocal(),
    updatedAt: DateTime.parse(json['updated_at']).toLocal(),
  );

  static Uint8List _hexToUint8List(String hex) {
    if (hex.length % 2 != 0) {
      throw 'Invalid hex string';
    }
    final Uint8List bytes = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      final String char = hex.substring(i * 2, i * 2 + 2);
      bytes[i] = int.parse(char, radix: 16);
    }
    return bytes;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'code': code,
    'name': name,
    'original_price': originalPrice,
    'selling_price': sellingPrice,
    'quantity': quantity,
    'weight': weight,
    'expiry_date': expiryDate?.toIso8601String(),
    'image': image,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  ProductModel copyWith({String? id, String? code, String? name, double? sellingPrice, double? originalPrice, int? quantity, String? weight, DateTime? expiryDate, Uint8List? image, DateTime? createdAt, DateTime? updatedAt}) => ProductModel(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    originalPrice: originalPrice ?? this.originalPrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    quantity: quantity ?? this.quantity,
    weight: weight ?? this.weight,
    expiryDate: expiryDate ?? this.expiryDate,
    image: image ?? this.image,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
