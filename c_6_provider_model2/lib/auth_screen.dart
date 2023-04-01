import 'package:c_6_provider_model2/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, signup }

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();
  final Map<String, String> _authData = {'email': "", 'password': ""};
  AuthMode _authMode = AuthMode.login;
  bool isLoading = false;

  void checkAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_authMode == AuthMode.login ? 'LogIn' : 'SignUp'),
      ),
      body: Container(
        color: Theme.of(context).secondaryHeaderColor,
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: "E-Mail", border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val!.isEmpty || !val.contains("@")) {
                            return "Invalid E-Mail!";
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _authData["email"] = val!;
                          print("Hello ${_authData['email']}");
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder()),
                        controller: _passController,
                        obscureText: true,
                        validator: (val) {
                          if (val!.isEmpty || val.length <= 5) {
                            return "Password is too short";
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _authData["password"] = val!;
                          print("Your Pass is ${_authData['password']}");
                        },
                      ),
                    ),
                    if (_authMode == AuthMode.signup)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Confirm Password",
                                border: OutlineInputBorder()),
                            obscureText: true,
                            enabled: _authMode == AuthMode.signup,
                            validator: _authMode == AuthMode.signup
                                ? (val) {
                                    if (val != _passController.text) {
                                      return "Password not Match";
                                    }
                                    return null;
                                  }
                                : null),
                      ),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 150,
                              child: FilledButton(
                                onPressed: _submit,
                                child: Text(_authMode == AuthMode.login
                                    ? "LogIn"
                                    : "Sign Up"),
                              ),
                            ),
                          ),
                    TextButton(
                        onPressed: checkAuthMode,
                        child: Text(
                            '${_authMode == AuthMode.signup ? 'LogIn' : 'SignUp'} Instead?',
                            style: const TextStyle(
                                decoration: TextDecoration.underline))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Authentication>(context, listen: false)
            .logIn(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Authentication>(context, listen: false)
            .signUp(_authData['email']!, _authData['password']!);
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Error'),
                content: Text('$e'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Okey'))
                ],
              ));
    }
    setState(() {
      isLoading = false;
    });
  }
}
