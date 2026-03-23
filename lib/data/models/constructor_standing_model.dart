import 'package:hive/hive.dart';

part 'constructor_standing_model.g.dart';

@HiveType(typeId: 3)
class ConstructorStandingModel extends HiveObject {
  @HiveField(0)
  final int position;

  @HiveField(1)
  final String constructorId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String nationality;

  @HiveField(4)
  final double points;

  @HiveField(5)
  final int wins;

  ConstructorStandingModel({
    required this.position,
    required this.constructorId,
    required this.name,
    required this.nationality,
    required this.points,
    required this.wins,
  });

  factory ConstructorStandingModel.fromJson(Map<String, dynamic> json, int pos) {
    final c = json['Constructor'] as Map<String, dynamic>;
    return ConstructorStandingModel(
      position: pos,
      constructorId: c['constructorId'] as String? ?? '',
      name: c['name'] as String? ?? '',
      nationality: c['nationality'] as String? ?? '',
      points: double.tryParse(json['points']?.toString() ?? '0') ?? 0,
      wins: int.tryParse(json['wins']?.toString() ?? '0') ?? 0,
    );
  }
}
