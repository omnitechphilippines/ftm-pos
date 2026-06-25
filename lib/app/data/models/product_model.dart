import 'dart:typed_data';
import 'package:hex/hex.dart';

class ProductModel {
  final String id;
  final String code;
  final String name;
  final double originalPrice;
  final double sellingPrice;
  int quantity;
  final String? weight;
  final DateTime? expiryDate;
  final Uint8List? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({required this.id, required this.code, required this.name, required this.originalPrice, required this.sellingPrice, required this.quantity, this.weight, this.expiryDate, required this.image, required this.createdAt, required this.updatedAt});

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] ?? '',
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
    sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
    quantity: json['quantity'] ?? 0,
    weight: json['weight'] ?? '',
    expiryDate: DateTime.tryParse(json['expiry_date'] ?? '')?.toLocal(),
    image: json['image'] != null && json['image'].toString().length > 2 ? Uint8List.fromList(HEX.decode(json['image'].substring(2))) : null,
    createdAt: DateTime.parse(json['created_at'] ?? '').toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] ?? '').toLocal(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'code': code,
    'name': name,
    'original_price': originalPrice,
    'selling_price': sellingPrice,
    'quantity': quantity,
    'weight': weight,
    'expiry_date': expiryDate?.toUtc().toIso8601String(),
    'image': image != null ? '\\x${HEX.encode(image!)}' : null,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
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
