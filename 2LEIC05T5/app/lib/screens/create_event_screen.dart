import 'package:app/resources/notification_methods.dart';
import 'package:app/resources/storage_methods.dart';
import 'package:app/widgets/error_message.dart';
import 'package:app/model/event.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/widgets/attach_photo.dart';
import 'package:app/widgets/date_picker.dart';
import 'package:app/widgets/location_autocomplete.dart';
import 'package:app/widgets/time_picker.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventScreen extends StatefulWidget {
  final Event? event;
  final Future<void> Function()? onEventUpdated;

  const CreateEventScreen({super.key, this.event, this.onEventUpdated});

  @override
  CreateEventState createState() => CreateEventState();
}

class CreateEventState extends State<CreateEventScreen> {
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionTextController =
      TextEditingController();
  DateTime _date = DateTime.now();
  Duration _durationFinal = const Duration();
  final TextEditingController _locationTextController = TextEditingController();
  XFile? _image;
  int maxNewLines = 3;
  XFile? _originalImage;
  String locationName = "";
  String _originalImageURL = "";
  List<String> _enrolled = [];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleTextController.text = widget.event!.title; // Done
      _descriptionTextController.text = widget.event!.description; // Done
      _date = widget.event!.time; // Done
      _durationFinal =
          _parseDuration(widget.event!.duration); // Done (duration)
      _enrolled = widget.event!.enrolledUsers;
      locationName =
          widget.event!.locationName; // Formatting might be required here too
      _originalImageURL = widget.event!.urlImage;
      _originalImage = _originalImageURL != ""
          ? XFile(_originalImageURL)
          : null; // Assuming the image path is stored as a URL
      _image = _originalImage;
      print("Original URL image: $_originalImageURL");
      print("Original image: $_originalImage");
    }
    print("Duration date: $_durationFinal");
  }

  Duration _parseDuration(String durationStr) {
    List<String> parts = durationStr.split(':');
    return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2].split('.')[0]));
  }

  Future<String> createEvent() async {
    String res = await StorageMethods().createEvent(
      title: _titleTextController.text,
      description: _descriptionTextController.text,
      duration: _durationFinal,
      time: _date,
      location: locationName,
      image: _image,
    );

    if (res == "success") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    function: () {
                      showErrorMessage(context, "Event created!!");
                    },
                  )));
    } else {
      // ignore: use_build_context_synchronously
      showErrorMessage(context, res);
    }
    return res;
  }

  Future<void> updateEvent(String? eventId) async {
    String tmpEventId = eventId ?? '';

    String result = await StorageMethods().editEvent(
      eventId: tmpEventId,
      title: _titleTextController.text,
      description: _descriptionTextController.text,
      time: _date,
      duration: _durationFinal,
      location: locationName,
      image: _image,
      oldImageURL: _originalImageURL,
      enrolled: _enrolled,
    );

    if (result == 'success') {
      // ignore: use_build_context_synchronously
      if (widget.onEventUpdated != null) {
        widget.onEventUpdated!();
      }
      Navigator.pop(context);
    } else {
      // ignore: use_build_context_synchronously
      showErrorMessage(context, result);
    }
  }

  void updateLocation(String newText) {
    setState(() {
      locationName = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.event != null;
    String? eventId = widget.event?.eid;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              decoration:  BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(56),
                  topRight: Radius.circular(56),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CustomAppBar(
                        title: 'CleanCity',
                        leftIcon: Icons.arrow_back_ios_new_rounded,
                        leftAction: () async {
                          Navigator.pop(
                            context,
                          );
                        },
                        rightAction: () {}),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEditing ? "Edit Event" : "Create Event",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontFamily: 'Comfortaa',
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20), // Adjust horizontal padding
                            child: TextField(
                              controller: _titleTextController,
                              obscureText: false,
                              maxLength: 30,
                              decoration: InputDecoration(
                                counter: SizedBox.shrink(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color:Theme.of(context).colorScheme.onPrimary, width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                hintText: "Write the title",
                                labelText: "Title",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    LocationAutocomplete(
                      locationName: locationName,
                      onChanged: (value) {
                        setState(() {
                          locationName = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomDatePicker(
                      key: ValueKey(_date),
                      date: _date,
                      onChanged: (DateTime newValue) {
                        setState(() {
                          _date = newValue;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTimePicker(
                      durationFinal: _durationFinal,
                      onChanged: (value) {
                        setState(() {
                          _durationFinal = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              maxLines: 4,
                              maxLength: 200,
                              controller: _descriptionTextController,
                              obscureText: false,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                hintText: "Write your description here ...",
                                labelText: "Description",
                                alignLabelWithHint:
                                    true, // Align labelText with hintText
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CustomAttachPhoto(
                            selectedImage: _image,
                            onChanged: (value) {
                              setState(() {
                                _image = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 170,
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side:  BorderSide(
                                    color: Theme.of(context).colorScheme.secondary, width: 2),
                              ),
                              fixedSize: const Size(100, 50),
                            ),
                            child:  Text(
                              "Cancel",

                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),

                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 170,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: isEditing
                                ? () async {
                                    updateEvent(eventId);
                                  }
                                : () async {
                                    createEvent();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              fixedSize: const Size(100, 50),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
