import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/create_account.dart';
import 'package:flutter_share/pages/profile.dart';
import 'package:flutter_share/pages/search.dart';
import 'package:flutter_share/pages/timeline.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'activity_feed.dart';
import 'upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final firestore = Firestore.instance.collection('users');
final StorageReference storageRef = FirebaseStorage.instance.ref();
final postRef = Firestore.instance.collection('posts');
DateTime timeStamp = DateTime.now();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController _pageController;
  int _pageIndex = 0;
  User currentUser;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    //detects when user signed in.
    googleSignIn.onCurrentUserChanged.listen((account) {
      handelSignIn(account);
    }, onError: (error) {
      print('Error Occured when signing in: $error');
    });
    //Reauthenticating user when app is opened:
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handelSignIn(account);
    }).catchError((error) {
      print('Error Occured when signing in: $error');
    });
  }

  handelSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserinFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserinFirestore() async {
    // 1) check if user exists in database using their id.
    final user = googleSignIn.currentUser;
    DocumentSnapshot doc = await firestore.document(user.id).get();

    //2) doesnt exist, otherwise navigate to acccount creation page.
    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
      //3) get username and create a new user in users collection
      firestore.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayname': user.displayName,
        'bio': '',
        'timestamp': timeStamp,
      });

      doc = await firestore.document(user.id).get();
    }
    //saving a user to a current user to be passed to various pgs.
    currentUser = User.fromDocument(doc);
    // print(currentUser);
    // print(currentUser.username);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logOut() {
    googleSignIn.signOut();
  }

  _onPageChanged(int pageIndex) {
    setState(() {
      pageIndex = _pageIndex;
    });
  }

  _onTap(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          //Timeline(),
          RaisedButton(
            onPressed: logOut,
            child: Text('LogOut'),
          ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics:
            NeverScrollableScrollPhysics(), //Pages wont be scrollable but widgets inside the page will scroll
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _pageIndex,
        onTap: _onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 35.0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );

    //RaisedButton(
    //   onPressed: logOut,
    //   child: Text('LogOut'),
    // );
  }

  Scaffold buildUnAuthSCreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.teal,
              Colors.purple,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'FlutterShare',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 80.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              onTap: login,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthSCreen();
  }
}
