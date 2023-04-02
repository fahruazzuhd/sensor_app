import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:sensor_app/src/pages/home_page.dart';
import 'package:sensor_app/src/models/user_model.dart';

import '../database/users_db_helper.dart';

class LoginPage extends StatelessWidget {
  Users? users;


  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  DbHelper db = DbHelper();

  // TextEditingController? email;
  Future<String?> _loginUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (users!.password != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    // debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      insertUser(data.name!, data.password!);
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      // if (!users.containsKey(name)) {
      //   return 'User not exists';
      // }
      return "sds";
    });
  }

  Future<void> insertUser(String email, String password) async {
      await db.saveUsers(Users(
        email: email,
        password: password,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      onLogin: _loginUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      },
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
    );
  }
}