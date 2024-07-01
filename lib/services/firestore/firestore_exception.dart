// firestore_errors.dart

class FirebaseSaveUsernameException implements Exception {
  final String message;

  FirebaseSaveUsernameException({this.message = 'Error saving username to Firestore.'});

  @override
  String toString() {
    return 'FirebaseSaveUsernameException: $message';
  }
}

class FirebaseOtherOperationException implements Exception {
  final String message;

  FirebaseOtherOperationException({this.message = 'Error performing Firestore operation.'});

  @override
  String toString() {
    return 'FirebaseOtherOperationException: $message';
  }
}

// Add more custom exceptions as needed for different Firestore operations
