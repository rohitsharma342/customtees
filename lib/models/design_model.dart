import 'package:flutter/material.dart';

class DesignElement {
  final String id;
  final DesignElementType type;
  String content;
  Offset position;
  double scale;
  double rotation;
  Color? textColor;
  String? fontFamily;
  double? fontSize;

  DesignElement({
    required this.id,
    required this.type,
    required this.content,
    this.position = const Offset(100, 100),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.textColor,
    this.fontFamily,
    this.fontSize,
  });

  DesignElement copyWith({
    String? id,
    DesignElementType? type,
    String? content,
    Offset? position,
    double? scale,
    double? rotation,
    Color? textColor,
    String? fontFamily,
    double? fontSize,
  }) {
    return DesignElement(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      textColor: textColor ?? this.textColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

enum DesignElementType { text, image }

class CustomDesign {
  final String id;
  final String name;
  final Color tshirtColor;
  final List<DesignElement> elements;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomDesign({
    required this.id,
    required this.name,
    required this.tshirtColor,
    required this.elements,
    required this.createdAt,
    required this.updatedAt,
  });

  CustomDesign copyWith({
    String? id,
    String? name,
    Color? tshirtColor,
    List<DesignElement>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomDesign(
      id: id ?? this.id,
      name: name ?? this.name,
      tshirtColor: tshirtColor ?? this.tshirtColor,
      elements: elements ?? this.elements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}