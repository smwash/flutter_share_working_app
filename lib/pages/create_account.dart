import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_share/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _username;

  _submitForm() {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      _formKey.currentState.save();
      SnackBar snackBar = SnackBar(
        content: Text('Welcome $_username'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(
        Duration(seconds: 2),
        () {
          Navigator.pop(context, _username);
        },
      );
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        titleText: 'Set Up Your Profile',
        removeBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(
            20.0,
          ),
          child: Column(
            children: [
              Text(
                'Create your Username',
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'UserName',
                    labelStyle: TextStyle(
                      fontSize: 17.0,
                    ),
                    helperText: 'Must be atleast 3 characters',
                  ),
                  autovalidate: true,
                  validator: (value) {
                    if (value.isEmpty || value.trim().length < 3) {
                      return 'Please enter a username';
                    } else if (value.trim().length > 12) {
                      return 'Please shorten the username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value;
                  },
                ),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.blue,
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
