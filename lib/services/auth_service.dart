import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user_model.dart';
import '../models/parent_child_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user model
  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      developer.log(
        'Error getting current user model: $e',
        name: 'AuthService',
      );
      return null;
    }
  }

  // Sign up with email and password (with role)
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? parentId, // For child users
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user model
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        parentId: parentId,
        childrenIds: role == UserRole.parent ? [] : null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());

      // If this is a child user, create parent-child relationship
      if (role == UserRole.child && parentId != null) {
        await _createParentChildRelationship(
          parentId,
          userCredential.user!.uid,
        );
      }

      return userModel;
    } catch (e) {
      developer.log('Sign up error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLoginAt': FieldValue.serverTimestamp()},
      );

      return await getCurrentUserModel();
    } catch (e) {
      developer.log('Sign in error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user model for Google sign-in
        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName ?? 'User',
          role: UserRole.child, // Default to child for Google sign-in
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      } else {
        // Update last login time
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': FieldValue.serverTimestamp()});

        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log('Google sign-in error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Sign in with phone number
  Future<String?> signInWithPhone(String phoneNumber) async {
    try {
      String? verificationId;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          developer.log('Phone verification failed: $e', name: 'AuthService');
          throw e;
        },
        codeSent: (String vid, int? resendToken) {
          verificationId = vid;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      return verificationId;
    } catch (e) {
      developer.log('Phone sign-in error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Verify OTP
  Future<UserModel?> verifyOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user model for phone sign-in
        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.phoneNumber ?? '',
          displayName: 'Phone User',
          role: UserRole.child, // Default to child for phone sign-in
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      } else {
        // Update last login time
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': FieldValue.serverTimestamp()});

        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log('OTP verification error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserModel?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        oauthCredential,
      );

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user model for Apple sign-in
        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName ?? 'Apple User',
          role: UserRole.child, // Default to child for Apple sign-in
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      } else {
        // Update last login time
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': FieldValue.serverTimestamp()});

        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log('Apple sign-in error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Sign in with Microsoft
  Future<UserModel?> signInWithMicrosoft() async {
    try {
      // Note: Microsoft sign-in requires additional setup with Azure AD
      // This is a placeholder implementation
      developer.log('Microsoft sign-in attempted', name: 'AuthService');

      // For now, we'll simulate a successful sign-in
      // In production, implement proper Microsoft OAuth flow
      await Future.delayed(const Duration(seconds: 2));

      // Create a mock user for demonstration
      // Replace this with actual Microsoft OAuth implementation
      final mockCredential = await _createMockCredential(
        'microsoft_user@test.com',
        'Microsoft User',
      );

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(mockCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user model for Microsoft sign-in
        UserModel userModel = UserModel(
          uid: mockCredential.user!.uid,
          email: mockCredential.user!.email ?? 'microsoft_user@test.com',
          displayName: 'Microsoft User',
          role: UserRole.child, // Default to child for Microsoft sign-in
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(mockCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      } else {
        // Update last login time
        await _firestore
            .collection('users')
            .doc(mockCredential.user!.uid)
            .update({'lastLoginAt': FieldValue.serverTimestamp()});

        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log('Microsoft sign-in error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Sign in with Slack
  Future<UserModel?> signInWithSlack() async {
    try {
      // Note: Slack sign-in requires Slack OAuth setup
      // This is a placeholder implementation
      developer.log('Slack sign-in attempted', name: 'AuthService');

      // For now, we'll simulate a successful sign-in
      // In production, implement proper Slack OAuth flow
      await Future.delayed(const Duration(seconds: 2));

      // Create a mock user for demonstration
      // Replace this with actual Slack OAuth implementation
      final mockCredential = await _createMockCredential(
        'slack_user@test.com',
        'Slack User',
      );

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(mockCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user model for Slack sign-in
        UserModel userModel = UserModel(
          uid: mockCredential.user!.uid,
          email: mockCredential.user!.email ?? 'slack_user@test.com',
          displayName: 'Slack User',
          role: UserRole.child, // Default to child for Slack sign-in
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(mockCredential.user!.uid)
            .set(userModel.toJson());

        return userModel;
      } else {
        // Update last login time
        await _firestore
            .collection('users')
            .doc(mockCredential.user!.uid)
            .update({'lastLoginAt': FieldValue.serverTimestamp()});

        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log('Slack sign-in error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Helper method to create mock credentials for demonstration
  // Remove this method in production and implement proper OAuth flows
  Future<UserCredential> _createMockCredential(
    String email,
    String displayName,
  ) async {
    try {
      // Create a temporary anonymous user for demonstration
      UserCredential userCredential = await _auth.signInAnonymously();

      // Update the user's display name
      await userCredential.user!.updateDisplayName(displayName);

      return userCredential;
    } catch (e) {
      developer.log('Mock credential creation error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Generate parent-child linking code
  Future<String> generateParentChildCode(String parentId) async {
    try {
      String code = ParentChildCodeManager.generateParentChildCode();

      // Check if code already exists
      QuerySnapshot existingCodes = await _firestore
          .collection('parent_child_codes')
          .where('parentChildCode', isEqualTo: code)
          .get();

      if (existingCodes.docs.isNotEmpty) {
        // Generate new code if collision
        code = ParentChildCodeManager.generateParentChildCode();
      }

      // Save the code
      await _firestore.collection('parent_child_codes').add({
        'parentId': parentId,
        'parentChildCode': code,
        'createdAt': FieldValue.serverTimestamp(),
        'isUsed': false,
      });

      return code;
    } catch (e) {
      developer.log(
        'Error generating parent-child code: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }

  // Link child to parent using code
  Future<bool> linkChildToParent(String code, String childId) async {
    try {
      // Find the code in Firestore
      QuerySnapshot codeQuery = await _firestore
          .collection('parent_child_codes')
          .where('parentChildCode', isEqualTo: code.toUpperCase())
          .where('isUsed', isEqualTo: false)
          .get();

      if (codeQuery.docs.isEmpty) {
        throw Exception('Invalid or expired code');
      }

      String parentId = codeQuery.docs.first['parentId'];

      // Create parent-child relationship
      await _createParentChildRelationship(parentId, childId);

      // Mark code as used
      await codeQuery.docs.first.reference.update({'isUsed': true});

      return true;
    } catch (e) {
      developer.log('Error linking child to parent: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Create parent-child relationship
  Future<void> _createParentChildRelationship(
    String parentId,
    String childId,
  ) async {
    try {
      String relationshipId = '${parentId}_$childId';

      ParentChildRelationship relationship = ParentChildRelationship(
        id: relationshipId,
        parentId: parentId,
        childId: childId,
        parentChildCode: ParentChildCodeManager.generateParentChildCode(),
        linkedAt: DateTime.now(),
        childPermissions: ParentChildRelationship.getDefaultChildPermissions(),
        parentControls: ParentChildRelationship.getDefaultParentControls(),
      );

      // Save relationship
      await _firestore
          .collection('parent_child_relationships')
          .doc(relationshipId)
          .set(relationship.toJson());

      // Update parent user model
      await _firestore.collection('users').doc(parentId).update({
        'childrenIds': FieldValue.arrayUnion([childId]),
      });

      // Update child user model
      await _firestore.collection('users').doc(childId).update({
        'parentId': parentId,
      });
    } catch (e) {
      developer.log(
        'Error creating parent-child relationship: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }

  // Get children for a parent
  Future<List<UserModel>> getChildrenForParent(String parentId) async {
    try {
      DocumentSnapshot parentDoc = await _firestore
          .collection('users')
          .doc(parentId)
          .get();

      if (!parentDoc.exists) return [];

      UserModel parent = UserModel.fromJson(
        parentDoc.data() as Map<String, dynamic>,
      );

      if (parent.childrenIds == null || parent.childrenIds!.isEmpty) {
        return [];
      }

      List<UserModel> children = [];
      for (String childId in parent.childrenIds!) {
        DocumentSnapshot childDoc = await _firestore
            .collection('users')
            .doc(childId)
            .get();

        if (childDoc.exists) {
          children.add(
            UserModel.fromJson(childDoc.data() as Map<String, dynamic>),
          );
        }
      }

      return children;
    } catch (e) {
      developer.log(
        'Error getting children for parent: $e',
        name: 'AuthService',
      );
      return [];
    }
  }

  // Get parent for a child
  Future<UserModel?> getParentForChild(String childId) async {
    try {
      DocumentSnapshot childDoc = await _firestore
          .collection('users')
          .doc(childId)
          .get();

      if (!childDoc.exists) return null;

      UserModel child = UserModel.fromJson(
        childDoc.data() as Map<String, dynamic>,
      );

      if (child.parentId == null) return null;

      DocumentSnapshot parentDoc = await _firestore
          .collection('users')
          .doc(child.parentId!)
          .get();

      if (parentDoc.exists) {
        return UserModel.fromJson(parentDoc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      developer.log('Error getting parent for child: $e', name: 'AuthService');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log('Sign out error: $e', name: 'AuthService');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        // Delete from Firestore first
        await _firestore.collection('users').doc(currentUser!.uid).delete();

        // Delete from Firebase Auth
        await currentUser!.delete();
      }
    } catch (e) {
      developer.log('Delete account error: $e', name: 'AuthService');
      rethrow;
    }
  }
}
