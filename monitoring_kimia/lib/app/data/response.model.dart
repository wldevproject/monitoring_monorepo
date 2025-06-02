import 'dart:convert';

SensorData socketSolarPanelModelFromJson(String str) =>
    SensorData.fromJson(json.decode(str));

String socketSolarPanelModelToJson(SensorData data) =>
    json.encode(data.toJson());

class SensorData {
  final double? nilai;
  final int? kondisi;

  SensorData({
    this.nilai,
    this.kondisi,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) => SensorData(
        nilai: (json['nilai'] as num).toDouble(),
        kondisi: json['kondisi'] as int,
      );

  Map<String, dynamic> toJson() => {
        'nilai': nilai,
        'kondisi': kondisi,
      };
}
