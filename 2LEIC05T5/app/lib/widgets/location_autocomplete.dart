import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LocationAutocomplete extends StatefulWidget {
  String locationName;
  final ValueChanged<String> onChanged;

  LocationAutocomplete(
      {super.key, required this.locationName, required this.onChanged});

  @override
  _LocationAutocompleteState createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<LocationAutocomplete> {
  var uuid = const Uuid();
  String? selectedLocation;
  late Position _currentPosition;
  final String _sessionToken = "123456";
  List<dynamic> _list = [];
  var numberOfOptions = 4;
  @override
  void initState() {
    super.initState();
    // the position isnt working
    //_determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    setState(() {
      _currentPosition = position;
    });
  }

  String _formatLocation() {
    String r = "";
    r += _currentPosition.latitude.toString();
    if (_currentPosition.latitude > 0) {
      r += "%2C";
    }
    r += _currentPosition.longitude.toString();
    if (_currentPosition.longitude > 0) {
      r += "%2C";
    }
    return r;
  }

  void onChange(TextEditingController textEditingController) {
    getSuggestion(textEditingController.text);
  }

  void getSuggestion(String string) async {
    //String location =  await _formatLocation();
    String apiKey = ""; // hidden for security reasons
    String base =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    // add location here
    String request =
        '$base?input=$string&key=$apiKey&sessiontoken=$_sessionToken&locationbias=ipbias';
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        var test = jsonDecode(response.body.toString());
        _list = jsonDecode(response.body.toString())['predictions'];
        print(string);
        print("test");
        print(test);
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),

          child:
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return _list.map<String>((dynamic item) {
                  return item['description'] as String;
                }).toList();
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController controller,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                controller.text = widget.locationName;
                return TextField(
                  controller: controller,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
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
                    hintText: "Choose a location",
                    labelText: "Location",
                    alignLabelWithHint: true, // Align labelText with hintText
                  ),
                  onChanged: (text) {
                    widget.locationName = text;
                    onChange(controller);
                  },
                  onSubmitted: (text) {
                    setState(() {
                      widget.onChanged(text);
                    });
                  },
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onPrimary,
                              style: BorderStyle.solid,
                              width: 2.0,
                            ),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                          ),
                          width: MediaQuery.of(context).size.width - 40,
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: options.length,
                            separatorBuilder: (context, i) {
                              return const Divider();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              var title = options.elementAt(index);
                              return ListTile(
                                title: Text(title),
                                onTap: () {
                                  onSelected(title);
                                  setState(() {
                                    widget.onChanged(title);
                                  });
                                },
                                tileColor: Theme.of(context).colorScheme.primary,
                              );
                            },
                          )),
                    ));
              },
            ),

    );
  }
}
