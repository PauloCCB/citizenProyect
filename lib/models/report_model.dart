class ReportModel {
  final String id;
  final String title;
  final String description;
  final String generatedDetails;
  final DateTime reportDate;
  final List<String> tags;
  final double latitude;
  final double longitude;
  final String priority;
  final List<String> images;
  final List<String> relatedPersons;
  final DateTime createdAt;
  final bool isResolved;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.generatedDetails,
    required this.reportDate,
    required this.tags,
    required this.latitude,
    required this.longitude,
    required this.priority,
    required this.images,
    required this.relatedPersons,
    required this.createdAt,
    this.isResolved = false,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      generatedDetails: json['generated_details'],
      reportDate: DateTime.parse(json['report_date']),
      tags: List<String>.from(json['tags']),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      priority: json['priority'],
      images: List<String>.from(json['images']),
      relatedPersons: List<String>.from(json['related_persons']),
      createdAt: DateTime.parse(json['created_at']),
      isResolved: json['is_resolved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'generated_details': generatedDetails,
      'report_date': reportDate.toIso8601String(),
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
      'priority': priority,
      'images': images,
      'related_persons': relatedPersons,
      'created_at': createdAt.toIso8601String(),
      'is_resolved': isResolved,
    };
  }

  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    String? generatedDetails,
    DateTime? reportDate,
    List<String>? tags,
    double? latitude,
    double? longitude,
    String? priority,
    List<String>? images,
    List<String>? relatedPersons,
    DateTime? createdAt,
    bool? isResolved,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      generatedDetails: generatedDetails ?? this.generatedDetails,
      reportDate: reportDate ?? this.reportDate,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      priority: priority ?? this.priority,
      images: images ?? this.images,
      relatedPersons: relatedPersons ?? this.relatedPersons,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }
} 