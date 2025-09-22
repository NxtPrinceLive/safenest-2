import 'package:cloud_firestore/cloud_firestore.dart';

class ParentChildRelationship {
  final String id;
  final String parentId;
  final String childId;
  final String parentChildCode; // Unique code for linking
  final DateTime linkedAt;
  final bool isActive;
  final Map<String, dynamic>? childPermissions; // What the child can access
  final Map<String, dynamic>? parentControls; // What the parent can control

  ParentChildRelationship({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.parentChildCode,
    required this.linkedAt,
    this.isActive = true,
    this.childPermissions,
    this.parentControls,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'childId': childId,
      'parentChildCode': parentChildCode,
      'linkedAt': Timestamp.fromDate(linkedAt),
      'isActive': isActive,
      'childPermissions': childPermissions,
      'parentControls': parentControls,
    };
  }

  // Create from Firestore document
  factory ParentChildRelationship.fromJson(Map<String, dynamic> json) {
    return ParentChildRelationship(
      id: json['id'],
      parentId: json['parentId'],
      childId: json['childId'],
      parentChildCode: json['parentChildCode'],
      linkedAt: (json['linkedAt'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      childPermissions: json['childPermissions'],
      parentControls: json['parentControls'],
    );
  }

  // Default permissions for child
  static Map<String, dynamic> getDefaultChildPermissions() {
    return {
      'canViewLocation': true,
      'canViewScreenTime': true,
      'canViewAppUsage': true,
      'canSendEmergencyAlerts': true,
      'canContactParent': true,
      'canViewRules': true,
    };
  }

  // Default controls for parent
  static Map<String, dynamic> getDefaultParentControls() {
    return {
      'canTrackLocation': true,
      'canMonitorScreenTime': true,
      'canMonitorAppUsage': true,
      'canSetAppLimits': true,
      'canSetTimeLimits': true,
      'canBlockApps': true,
      'canBlockWebsites': true,
      'canSetGeofences': true,
      'canReceiveAlerts': true,
    };
  }

  // Create a copy with updated fields
  ParentChildRelationship copyWith({
    String? id,
    String? parentId,
    String? childId,
    String? parentChildCode,
    DateTime? linkedAt,
    bool? isActive,
    Map<String, dynamic>? childPermissions,
    Map<String, dynamic>? parentControls,
  }) {
    return ParentChildRelationship(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      parentChildCode: parentChildCode ?? this.parentChildCode,
      linkedAt: linkedAt ?? this.linkedAt,
      isActive: isActive ?? this.isActive,
      childPermissions: childPermissions ?? this.childPermissions,
      parentControls: parentControls ?? this.parentControls,
    );
  }
}

// Helper class for managing parent-child codes
class ParentChildCodeManager {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final _random = DateTime.now().millisecondsSinceEpoch;

  // Generate a unique 6-character code for parent-child linking
  static String generateParentChildCode() {
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += _chars[(_random + i * 1000) % _chars.length];
    }
    return code;
  }

  // Validate code format (6 alphanumeric characters)
  static bool isValidParentChildCode(String code) {
    return RegExp(r'^[A-Z0-9]{6}$').hasMatch(code.toUpperCase());
  }
}
