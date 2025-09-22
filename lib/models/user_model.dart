import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { parent, child }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? parentId; // For child users, reference to parent
  final List<String>? childrenIds; // For parent users, list of children
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.parentId,
    this.childrenIds,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.isActive = true,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isActive': isActive,
    };
  }

  // Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.child,
      ),
      parentId: json['parentId'],
      childrenIds: json['childrenIds'] != null
          ? List<String>.from(json['childrenIds'])
          : null,
      profileImageUrl: json['profileImageUrl'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? parentId,
    List<String>? childrenIds,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper methods
  bool get isParent => role == UserRole.parent;
  bool get isChild => role == UserRole.child;
  bool get hasParent => parentId != null && parentId!.isNotEmpty;
  bool get hasChildren => childrenIds != null && childrenIds!.isNotEmpty;
}
