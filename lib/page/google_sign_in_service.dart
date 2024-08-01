import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '380369825003-pn4dcsi5l5hm3vtd7fn0ef11bjeqqtro.apps.googleusercontent.com',
    scopes: <String>['email', 'profile'],
  );

  GoogleSignInAccount? _currentUser;
  String _accessToken = '';

  GoogleSignInAccount? get currentUser => _currentUser;
  String get accessToken => _accessToken;

  Future<void> signInSilently() async {
    final account = await _googleSignIn.signInSilently();
    if (account != null) {
      _currentUser = account;
      _accessToken = (await account.authentication).accessToken!;
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account != null) {
      _currentUser = account;
      _accessToken = (await account.authentication).accessToken!;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _accessToken = '';
    notifyListeners();
  }

  bool isAuthorized() => _currentUser != null;
}
