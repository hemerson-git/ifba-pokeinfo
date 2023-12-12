// ignore_for_file: unnecessary_getters_setters
import 'package:google_sign_in/google_sign_in.dart';

class User {
  String? _name = "";
  String? get name => _name;
  set name(String? name) {
    _name = name;
  }

  String _email = "";
  String get email => _email;
  set email(String email) {
    _email = email;
  }

  User(String? name, String email) {
    _name = name;
    _email = email;
  }
}

class Auth {
  static Future<User> login() async {
    try {
      final gUser = await GoogleSignIn(scopes: ["email"]).signIn();
      final user = User(gUser!.displayName, gUser.email);
      return user;
    } catch (error) {
      print(error);
      throw Error();
    }
  }

  static Future<User?> recoverUser() async {
    User? user;

    final gSignIn = GoogleSignIn(scopes: ['email']);
    if (await gSignIn.isSignedIn()) {
      await gSignIn.signInSilently();

      final gUser = gSignIn.currentUser;
      if (gUser != null) {
        user = User(gUser.displayName, gUser.email);
      }
    }
    // final user = User("Avemarilson da Silva", "avema_2002@gmail.com");

    return user;
  }

  static Future<void> logout() async {
    await GoogleSignIn().signOut();
  }
}
