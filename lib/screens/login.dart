import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feathersjs/flutter_feathersjs.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/wrapper.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../core/my_settings.dart';

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

enum Status { login, checking, successful, failed }

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Status state = Status.login;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: uiState.isDesktop ? 128 : 11,
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
                  if (state == Status.login)
                    ...loginForm(context, settings)
                  else if (state == Status.checking)
                    ...checkingView(context, settings)
                  else if (state == Status.successful)
                    ...successfulView(context, settings)
                  else if (state == Status.failed)
                    ...errorView(context, settings)
                ],
              ),
            ),
            if (state == Status.login) ...[
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
          ],
        ),
      ),
    );
  }

  List<Widget> loginForm(BuildContext context, MySettings settings) {
    return [
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
        onFieldSubmitted: (value) {
          login(settings);
        },
        autofocus: true,
        controller: emailController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          label: Text(AppLocalizations.of(context).translate("Email")),
          suffixIcon: const Icon(Icons.email),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 16),
      TextFormField(
        onFieldSubmitted: (value) {
          login(settings);
        },
        controller: passwordController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          label: Text(AppLocalizations.of(context).translate("Password")),
          suffixIcon: const Icon(Icons.lock),
        ),
        obscureText: true,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
          ),
          Text(
            AppLocalizations.of(context).translate("Remember Me"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Expanded(child: SizedBox()),
          // TextButton(
          //   onPressed: () {},
          //   child: const Text("Forgot Password ?"),
          // )
        ],
      ),
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
    ];
  }

  List<Widget> checkingView(BuildContext context, MySettings settings) {
    return [
      const Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: LoadingIndicator(
            indicatorType: Indicator.orbit,
            colors: [Colors.red],
            strokeWidth: 1.0,
            pathBackgroundColor: Colors.black45,
          ),
        ),
      ),
    ];
  }

  List<Widget> successfulView(BuildContext context, MySettings settings) {
    return [];
  }

  List<Widget> errorView(BuildContext context, MySettings settings) {
    return [
      Text(
        error,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 32),
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 48,
        child: ElevatedButton(
          autofocus: true,
          onPressed: () {
            setState(() {
              state = Status.login;
              error = '';
            });
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text("Retry"),
        ),
      ),
    ];
  }

  void signin(MySettings settings) async {
    setState(() {
      state = Status.checking;
      error = '';
    });
    try {
      var response = await Api.feathers().create(serviceName: "users", data: {
        "email": emailController.text,
        "password": passwordController.text,
      });

      updateSettings(settings, response);
    } catch (e) {
      if (e is FeatherJsError) {
        if (e.error is Map) {
          setState(() {
            state = Status.failed;
            error = e.error['message'];
          });
          return;
        }
      }
      setState(() {
        state = Status.failed;
        error = 'authentication Failed';
      });
    }
  }

  void login(MySettings settings) async {
    setState(() {
      state = Status.checking;
      error = '';
    });
    try {
      var response = await Api.feathers().create(serviceName: "authentication", data: {
        "strategy": "local",
        "email": emailController.text,
        "password": passwordController.text,
      });

      updateSettings(settings, response);
    } catch (e) {
      if (e is FeatherJsError) {
        if (e.error is Map) {
          setState(() {
            state = Status.failed;
            error = e.error['message'];
          });
          return;
        }
      }
      setState(() {
        state = Status.failed;
        error = 'authentication Failed';
      });
    }
  }

  void updateSettings(MySettings settings, dynamic response) {
    settings.login = emailController.text;
    settings.token = response['accessToken'] as String? ?? "";
    settings.saveAndNotify();

    final user = response['user'];
    if (user != null) {
      final oids = user['oids'];
      if (oids != null) {
        settings.companyId = oids[0];
        settings.saveAndNotify();
      }

      gohome(settings);
    }
  }

  void gohome(MySettings settings) {
    if (settings.token.isEmpty) {
      setState(() {
        state = Status.failed;
        error = "missing token";
      });
    } else {
      setState(() {
        state = Status.successful;
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
    }
  }
}
