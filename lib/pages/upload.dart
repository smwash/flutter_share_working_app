import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/models/user.dart';
import 'package:flutter_share/pages/home.dart';
import 'package:flutter_share/widgets/progress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  const Upload({Key key, this.currentUser}) : super(key: key);
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File pickedImage;
  final picker = ImagePicker();
  bool isUploading = false;
  String postId = Uuid().v4();
  final locationController = TextEditingController();
  final captionController = TextEditingController();

  handleTakePhoto() async {
    Navigator.pop(context);
    final file = await picker.getImage(
        source: ImageSource.camera, maxHeight: 675.0, maxWidth: 960);

    setState(() {
      pickedImage = File(file.path);
    });
  }

  handlePickedImage() async {
    Navigator.pop(context);
    final file = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = File(file.path);
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Text('Create Post'),
            children: [
              SimpleDialogOption(
                child: Text(
                  'Photo with camera',
                ),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text(
                  'Image from gallery',
                ),
                onPressed: handlePickedImage,
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });

    //final picker = ImagePicker();
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'images/upload.svg',
            height: 260.0,
          ),
          SizedBox(height: 15.0),
          RaisedButton(
            color: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Upload Image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            onPressed: () => selectImage(context),
          ),
        ],
      ),
    );
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imageFile);

    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    im.Image imageFile = im.decodeImage(
      pickedImage.readAsBytesSync(),
    );
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(
        im.encodeJpg(imageFile, quality: 85),
      );

    setState(() {
      pickedImage = compressedImageFile;
    });
  }

  createPostInFirestore({
    String mediaUrl,
    String location,
    String description,
  }) {
    postRef
        .document(widget.currentUser.id)
        .collection('userposts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timeStamp,
      'likes': {},
    });
  }

  handlePostSubmit() async {
    setState(() {
      isUploading = true;
    });

    await compressImage();
    String mediaUrl = await uploadImage(pickedImage);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();

    setState(() {
      pickedImage = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              pickedImage = null;
            });
          },
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handlePostSubmit(),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        //shrinkWrap: true,
        children: [
          isUploading ? linearProgress() : Text(''),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(
                        pickedImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.currentUser.photoUrl,
              ),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption..',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          // SizedBox(
          //   height: 8.0,
          // ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              icon: Icon(Icons.my_location, color: Colors.white),
              label: Text(
                'Use current location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: getUserLocation,
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality} ${placemark.subAdministrativeArea} ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';

    print(completeAddress);
    String formattedAddress =
        '${placemark.administrativeArea}, ${placemark.country}';

    locationController.text = formattedAddress;
    print(formattedAddress);
  }

  @override
  Widget build(BuildContext context) {
    return pickedImage == null ? buildSplashScreen() : buildUploadForm();
  }
}
