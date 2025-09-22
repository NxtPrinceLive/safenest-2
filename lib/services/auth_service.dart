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
      print('Error getting current user model: $e');
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
      print('Sign up error: $e');
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
      print('Sign in error: $e');
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
      print('Google sign-in error: $e');
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
          print('Phone verification failed: $e');
          throw e;
        },
        codeSent: (String vid, int? resendToken) {
          verificationId = vid;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      return verificationId;
    } catch (e) {
      print('Phone sign-in error: $e');
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
      print('OTP verification error: $e');
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
      print('Apple sign-in error: $e');
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
      print('Error generating parent-child code: $e');
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
      print('Error linking child to parent: $e');
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
      print('Error creating parent-child relationship: $e');
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
      print('Error getting children for parent: $e');
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
      print('Error getting parent for child: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
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
      print('Delete account error: $e');
      rethrow;
    }
  }
}
