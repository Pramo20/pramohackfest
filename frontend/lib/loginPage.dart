import 'package:flutter/material.dart';
import 'utilities.dart';
import 'package:toggle_switch/toggle_switch.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<String> typeNotifier = ValueNotifier<String>("Client");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 0, 0),
              child: Text(
                "YouSupply",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Column(
              children: [
                LabelledTextField.readable(
                  label: "Username",
                  controller: usernameController,
                ),
                PasswordField(
                  label1: "Password",
                  controller: passwordController,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder<String>(
                valueListenable: typeNotifier,
                builder: (context, value, child) {
                  return ToggleSwitch(
                    activeFgColor: Colors.white,
                    inactiveFgColor: Colors.white,
                    borderColor: [Colors.black45],
                    borderWidth: 1.5,
                    minWidth: 140,
                    minHeight: 50,
                    initialLabelIndex: value == "Client" ? 0 : 1,
                    totalSwitches: 2,
                    labels: const ['Client', 'Delivery Agent'],
                    activeBgColor: const [Colors.blueAccent],
                    inactiveBgColor: Colors.grey[850],
                    onToggle: (index) {
                      typeNotifier.value =
                          index == 0 ? "Client" : "Delivery Agent";
                    },
                  );
                },
              ),
            ),
            OutlinedButton(
              onPressed: () {
                authenticateUser(context);
              },
              style: OutlinedButton.styleFrom(
                shadowColor: Colors.black,
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
              ),
              child: const Text('Login'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signupGU');
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                    decorationColor: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void authenticateUser(BuildContext context) {
    //TODO authentication
    if (usernameController.text == "abc" && passwordController.text == "abc") {
      if (typeNotifier.value == "Client") {
        Navigator.pushNamed(context, '/homegu');
      } else {
        Navigator.pushNamed(context, '/homedel');
      }
    }
    else{
      if (typeNotifier.value == "Client") {
        Navigator.pushNamed(context, '/homegu');
      } else {
        Navigator.pushNamed(context, '/homedel');
      }
    }
  }
}
