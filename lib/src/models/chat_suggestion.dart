import 'dart:convert';

class Suggestion {
  final String name;
  final String careerTitle;

  Suggestion({
    required this.name,
    required this.careerTitle,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      name: json['name'],
      careerTitle: json['careerTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'careerTitle': careerTitle,
    };
  }
}
