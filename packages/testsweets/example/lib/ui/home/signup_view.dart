import 'package:example/ui/signup/signup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignUpViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: Center(
          child: MaterialButton(
            color: Colors.blue,
            child: Text(
              'Go to Login',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: model.navigateToOtherView,
          ),
        ),
      ),
      viewModelBuilder: () => SignUpViewModel(),
    );
  }
}
