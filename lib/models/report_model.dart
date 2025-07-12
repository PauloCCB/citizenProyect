import 'package:flutter/material.dart';
import 'user_model.dart';

class ReportModel {
  final String id;
  final String title;
  final String description;
  final String? generatedDetails;
  final DateTime reportedDate;
  final List<String> tags;
  final String lat;
  final String long;
  final String? priority;
  final int? priorityNumber;
  final List<String> images;
  final UserModel? user;
  final DateTime? createdAt;
  final bool? isResolved;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    this.generatedDetails,
    required this.reportedDate,
    required this.tags,
    required this.lat,
    required this.long,
    this.priority,
    this.priorityNumber,
    required this.images,
    this.user,
    this.createdAt,
    this.isResolved,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      generatedDetails: json['generated_details'],
      reportedDate: DateTime.parse(
        json['reported_date'] ?? DateTime.now().toIso8601String(),
      ),
      tags: List<String>.from(json['tags'] ?? []),
      lat: json['lat']?.toString() ?? '0.0',
      long: json['long']?.toString() ?? '0.0',
      priority: json['priority']?.toString(),
      priorityNumber: json['priority'] is int ? json['priority'] : null,
      images: List<String>.from(json['images'] ?? []),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isResolved: json['is_resolved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'generated_details': generatedDetails,
      'reported_date': reportedDate.toIso8601String(),
      'tags': tags,
      'lat': lat,
      'long': long,
      'priority': priorityNumber ?? priority,
      'images': images,
      'user': user?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'is_resolved': isResolved,
    };
  }

  String get priorityText {
    if (priority != null) return priority!;
    if (priorityNumber != null) {
      if (priorityNumber! >= 7) return 'ALTA';
      if (priorityNumber! >= 4) return 'MEDIA';
      return 'BAJA';
    }
    return 'BAJA';
  }

  Color get priorityColor {
    final p = priorityText.toUpperCase();
    switch (p) {
      case 'ALTA':
        return Colors.red;
      case 'MEDIA':
        return Colors.orange;
      case 'BAJA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    String? generatedDetails,
    DateTime? reportedDate,
    List<String>? tags,
    String? lat,
    String? long,
    String? priority,
    int? priorityNumber,
    List<String>? images,
    UserModel? user,
    DateTime? createdAt,
    bool? isResolved,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      generatedDetails: generatedDetails ?? this.generatedDetails,
      reportedDate: reportedDate ?? this.reportedDate,
      tags: tags ?? this.tags,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      priority: priority ?? this.priority,
      priorityNumber: priorityNumber ?? this.priorityNumber,
      images: images ?? this.images,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
