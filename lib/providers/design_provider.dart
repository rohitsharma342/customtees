import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/design_model.dart';
import '../data/static_data.dart';

class DesignProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<CustomDesign> _savedDesigns = [];
  CustomDesign? _currentDesign;
  List<CustomDesign> _undoStack = [];
  List<CustomDesign> _redoStack = [];
  String? _selectedElementId;

  DesignProvider() {
    _savedDesigns = List.from(StaticData.savedDesigns);
  }

  List<CustomDesign> get savedDesigns => List.unmodifiable(_savedDesigns);
  CustomDesign? get currentDesign => _currentDesign;
  String? get selectedElementId => _selectedElementId;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  DesignElement? get selectedElement {
    if (_currentDesign == null || _selectedElementId == null) return null;
    try {
      return _currentDesign!.elements.firstWhere((e) => e.id == _selectedElementId);
    } catch (_) {
      return null;
    }
  }

  void createNewDesign({Color tshirtColor = Colors.white}) {
    _saveToUndoStack();
    _currentDesign = CustomDesign(
      id: _uuid.v4(),
      name: 'Untitled Design',
      tshirtColor: tshirtColor,
      elements: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _selectedElementId = null;
    notifyListeners();
  }

  void loadDesign(CustomDesign design) {
    _saveToUndoStack();
    _currentDesign = design.copyWith(
      elements: design.elements.map((e) => e.copyWith()).toList(),
    );
    _selectedElementId = null;
    notifyListeners();
  }

  void setTshirtColor(Color color) {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    _currentDesign = _currentDesign!.copyWith(
      tshirtColor: color,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void addTextElement(String text, {Color? color, double? fontSize, String? fontFamily}) {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    final element = DesignElement(
      id: _uuid.v4(),
      type: DesignElementType.text,
      content: text,
      position: const Offset(100, 150),
      textColor: color ?? Colors.black,
      fontSize: fontSize ?? 24,
      fontFamily: fontFamily,
    );
    final newElements = List<DesignElement>.from(_currentDesign!.elements)..add(element);
    _currentDesign = _currentDesign!.copyWith(
      elements: newElements,
      updatedAt: DateTime.now(),
    );
    _selectedElementId = element.id;
    notifyListeners();
  }

  void addImageElement(String imageUrl) {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    final element = DesignElement(
      id: _uuid.v4(),
      type: DesignElementType.image,
      content: imageUrl,
      position: const Offset(100, 150),
    );
    final newElements = List<DesignElement>.from(_currentDesign!.elements)..add(element);
    _currentDesign = _currentDesign!.copyWith(
      elements: newElements,
      updatedAt: DateTime.now(),
    );
    _selectedElementId = element.id;
    notifyListeners();
  }

  void selectElement(String? elementId) {
    _selectedElementId = elementId;
    notifyListeners();
  }

  void updateElementPosition(String elementId, Offset position) {
    if (_currentDesign == null) return;
    final index = _currentDesign!.elements.indexWhere((e) => e.id == elementId);
    if (index >= 0) {
      _currentDesign!.elements[index].position = position;
      notifyListeners();
    }
  }

  void updateElementScale(String elementId, double scale) {
    if (_currentDesign == null) return;
    final index = _currentDesign!.elements.indexWhere((e) => e.id == elementId);
    if (index >= 0) {
      _currentDesign!.elements[index].scale = scale.clamp(0.5, 3.0);
      notifyListeners();
    }
  }

  void updateElementRotation(String elementId, double rotation) {
    if (_currentDesign == null) return;
    final index = _currentDesign!.elements.indexWhere((e) => e.id == elementId);
    if (index >= 0) {
      _currentDesign!.elements[index].rotation = rotation;
      notifyListeners();
    }
  }

  void updateTextColor(String elementId, Color color) {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    final index = _currentDesign!.elements.indexWhere((e) => e.id == elementId);
    if (index >= 0 && _currentDesign!.elements[index].type == DesignElementType.text) {
      _currentDesign!.elements[index].textColor = color;
      notifyListeners();
    }
  }

  void updateTextContent(String elementId, String content) {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    final index = _currentDesign!.elements.indexWhere((e) => e.id == elementId);
    if (index >= 0) {
      _currentDesign!.elements[index].content = content;
      notifyListeners();
    }
  }

  void updateFontSize(String elementId, double size) {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    final index = _currentDesign!.elements.indexWhere((e) => e.id == elementId);
    if (index >= 0 && _currentDesign!.elements[index].type == DesignElementType.text) {
      _currentDesign!.elements[index].fontSize = size.clamp(12, 72);
      notifyListeners();
    }
  }

  void removeElement(String elementId) {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    final newElements = _currentDesign!.elements.where((e) => e.id != elementId).toList();
    _currentDesign = _currentDesign!.copyWith(
      elements: newElements,
      updatedAt: DateTime.now(),
    );
    if (_selectedElementId == elementId) {
      _selectedElementId = null;
    }
    notifyListeners();
  }

  void _saveToUndoStack() {
    if (_currentDesign != null) {
      _undoStack.add(_currentDesign!.copyWith(
        elements: _currentDesign!.elements.map((e) => e.copyWith()).toList(),
      ));
      _redoStack.clear();
      if (_undoStack.length > 20) {
        _undoStack.removeAt(0);
      }
    }
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    if (_currentDesign != null) {
      _redoStack.add(_currentDesign!.copyWith(
        elements: _currentDesign!.elements.map((e) => e.copyWith()).toList(),
      ));
    }
    _currentDesign = _undoStack.removeLast();
    _selectedElementId = null;
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    if (_currentDesign != null) {
      _undoStack.add(_currentDesign!.copyWith(
        elements: _currentDesign!.elements.map((e) => e.copyWith()).toList(),
      ));
    }
    _currentDesign = _redoStack.removeLast();
    _selectedElementId = null;
    notifyListeners();
  }

  void reset() {
    if (_currentDesign == null) return;
    _saveToUndoStack();
    _currentDesign = _currentDesign!.copyWith(
      elements: [],
      updatedAt: DateTime.now(),
    );
    _selectedElementId = null;
    notifyListeners();
  }

  void saveDesign(String name) {
    if (_currentDesign == null) return;
    final design = _currentDesign!.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );
    final existingIndex = _savedDesigns.indexWhere((d) => d.id == design.id);
    if (existingIndex >= 0) {
      _savedDesigns[existingIndex] = design;
    } else {
      _savedDesigns.add(design);
    }
    notifyListeners();
  }

  void deleteDesign(String designId) {
    _savedDesigns.removeWhere((d) => d.id == designId);
    if (_currentDesign?.id == designId) {
      _currentDesign = null;
    }
    notifyListeners();
  }
}