import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package

class CustomAttachPhoto extends StatefulWidget {
  final ValueChanged<XFile?> onChanged;
  bool firstTime = true;
  XFile? selectedImage;

  CustomAttachPhoto({
    required this.onChanged,
    required this.selectedImage,
    super.key,
  });

  @override
  _GestureDetectorWithOptionsState createState() =>
      _GestureDetectorWithOptionsState();
}

class _GestureDetectorWithOptionsState extends State<CustomAttachPhoto> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    print(" This is the selected image: ");
    print(widget.selectedImage == null);
    return GestureDetector(
      onTap: () async {
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
                      widget.selectedImage = image;
                      widget.onChanged(image);
                    });
                  }
                  // Close modal
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () async {
                  // Open camera
                  var image = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  // Update selected image if image is not null
                  if (image != null) {
                    setState(() {
                      widget.selectedImage = image;
                      widget.onChanged(image);
                    });
                  }
                  // Close modal
                  Navigator.pop(context);
                },
              ),
            ];

            // Add "Remove Image" option if an image is selected
            if (widget.selectedImage != null) {
              options.add(
                ListTile(
                  leading: const Icon(Icons.remove_circle),
                  title: const Text('Remove Image'),
                  onTap: () {
                    // Remove selected image
                    setState(() {
                      widget.selectedImage = null;
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
                width: 2.0,
              ),
            ),
            child: widget.selectedImage != null
                ?  ClipOval(
                    child: Icon(
                      Icons.check,
                      size: 50.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                :  Icon(
                    Icons.add_rounded,
                    size: 50.0,
                    color:Theme.of(context).colorScheme.secondary,
                  ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            widget.selectedImage == null
                ? 'Add Image'
                : 'Uploaded Successfully',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
