import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api.dart';
import '../core/my_settings.dart';
import 'dart:convert';

import 'home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return const _DesktopLayout();
        },
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        // Expanded(child: PromotionImages()),
        Expanded(
          child: LoginForm(),
        ),
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 128,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const Image(
                //   image: AssetImage("assets/ic_pexel.png"),
                //   height: 48,
                //   width: 48,
                // ),
                // const SizedBox(height: 32),
                Text(
                  "Добро пожаловать!",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  autofocus: true,
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    label: const Text("Email"),
                    suffixIcon: const Icon(Icons.email),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    label: const Text("Password"),
                    suffixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                // const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Checkbox(
                //       value: false,
                //       onChanged: (value) {},
                //     ),
                //     Text(
                //       "Remeber Me",
                //       style: Theme.of(context).textTheme.bodyMedium,
                //     ),
                //     const Expanded(child: SizedBox()),
                //     TextButton(
                //       onPressed: () {},
                //       child: const Text("Forgot Password ?"),
                //     )
                //   ],
                // ),
                const SizedBox(height: 32),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      login(settings);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Login"),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account yet?",
                  style: Theme.of(context).textTheme.button,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    signin(settings);
                  },
                  child: const Text("Sign Up"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void signin(MySettings settings) async {
    try {
      var response = await Api.feathers().create(
          serviceName: "users", data: {
        "email": emailController.text,
        "password": passwordController.text,
      });

      updateSettings(settings, response);
    } catch (e) {
      print(e);
    }
  }


  void login(MySettings settings) async {
    try {
      var response = await Api.feathers().create(
          serviceName: "authentication", data: {
        "strategy": "local",
        "email": emailController.text,
        "password": passwordController.text,
      });

      updateSettings(settings, response);
    } catch (e) {
      print(e);
    }
  }

  void updateSettings(MySettings settings, dynamic response) {
    print("response: ");
    print(response);

    settings.token = response['accessToken'] as String ?? "";
    final user = response['user'];
    if (user != null) {
      final oids = user['oids'];

      print(oids);
      if (oids != null) {
        print("found oids");
        settings.selectedCompanyId = oids[0];
      }

      gohome(settings);
    }
  }

  void gohome(MySettings settings) {
    if (settings.token.isEmpty) {
      // TODO show warning screen
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePage()
          )
      );
    }
  }
}