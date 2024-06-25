import 'dart:io';
import 'package:app/resources/storage_methods.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package
import 'package:app/model/user.dart' as model;
import 'package:app/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';




class ProfilePhoto extends StatefulWidget {
  final bool othersprofile;
  final ValueChanged<XFile?> onChanged;
  final String urlothersimage;
   ProfilePhoto({
    required this.othersprofile,
    required this.onChanged,
    required this.urlothersimage,
    Key? key,
  }) : super(key: key);


  @override
  _GestureDetectorWithOptionsState createState() =>
      _GestureDetectorWithOptionsState();
}

class _GestureDetectorWithOptionsState extends State<ProfilePhoto> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage; // Initialize as nullable
  String urlProfileImage = '';
  User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    if(widget.othersprofile){
      urlProfileImage = widget.urlothersimage;
    }
    else{
        fetchUserData();
    }
  }


  Future<void> fetchUserData() async {

    model.User? fetchedUserData = await FireStoreMethods().getUserData(currentUser!.uid);


    setState(() {
        urlProfileImage = fetchedUserData!.urlProfileImage;
      });
}



    Future<void> cropImage() async {
    if (_selectedImage != null) {
    try {
      CroppedFile? croppedFile = await ImageCropper.platform.cropImage(
        sourcePath: _selectedImage!.path,
        cropStyle: CropStyle.circle,
        uiSettings: [
          IOSUiSettings(),
          AndroidUiSettings(toolbarTitle: '',

          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Theme.of(context).colorScheme.secondary,
          cropFrameColor: Colors.transparent,
          showCropGrid: false,
          lockAspectRatio: true,
          hideBottomControls: true,),
        ]
      );
      if (croppedFile != null) {
        setState(() {
          _selectedImage = XFile(croppedFile.path);
          widget.onChanged(_selectedImage);
        });
      }
      else{
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      print('Error cropping image: $e');
      // Handle the error, such as showing a snackbar or dialog to the user
    }
  }
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.othersprofile ? 
      null :
      () async {
        // Show modal bottom sheet or dialog with options
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            List<Widget> options = [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () async {
                  // Open image gallery
                  var image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  // Update selected image if image is not null
                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                    await cropImage();
                  }
                  // Close modal
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt  ),
                title: const Text('Take a Picture'),
                onTap: () async {
                  // Open camera
                  var image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  // Update selected image if image is not null
                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                    await cropImage();
                  }
                  // Close modal
                  Navigator.pop(context);
                },
              ),
            ];
          
            // Add "Remove Image" option if an image is selected
            if (_selectedImage != null) {
              options.add(
                ListTile(
                  leading: const Icon(Icons.remove_circle),
                  title: const Text('Remove Image'),
                  onTap: () {
                    // Remove selected image
                    setState(() {
                      _selectedImage = null;
                      widget.onChanged(null);
                    });
                    // Close modal
                    Navigator.pop(context);
                  },
                ),
              );
            }


            if (urlProfileImage != '') {
              options.add(
                ListTile(

                  leading: Icon(Icons.remove_circle),
                  title: const Text('Remove Image'),
                  onTap: () async{
                    // Remove selected image
                    await StorageMethods().deleteProfileImage(urlProfileImage);
                    setState(() {
                      urlProfileImage = '';
                      widget.onChanged(null);
                    });
                    
                    // Close modal
                    Navigator.pop(context);
                  },
                ),
              );
            }


            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options,
              ),
            );
          },
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: _selectedImage != null
                ? ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child:  Image.file(
                    File(_selectedImage!.path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  )
                : urlProfileImage != '' ?
                  ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child:  
                        Image.network(urlProfileImage,
                        width: 120.0,
                        height: 120.0, 
                        fit: BoxFit.cover,
                  ),
                  )
                  :

                   Icon(
                    Icons.account_circle,
                    size: 120.0,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
          ),
          widget.othersprofile ? 
          const SizedBox() :
          Positioned(
            bottom: 5,
            right: 140,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),

                  color: Theme.of(context).colorScheme.secondary),
              child:  Icon(
                Icons.edit,
                size: 20,
                color:Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
