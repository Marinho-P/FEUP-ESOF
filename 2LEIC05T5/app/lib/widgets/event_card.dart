import 'package:app/resources/firestore_methods.dart';
import 'package:app/widgets/error_message.dart';
import 'package:app/screens/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/model/event.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final bool showDescription;
  final VoidCallback? refreshEvents;

  const EventCard(
      {super.key,
      required this.event,
      required this.showDescription,
      this.refreshEvents});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String locationName = 'Loading location...';

  @override
  void initState() {
    super.initState();
    getLocationName(
        widget.event.location.latitude, widget.event.location.longitude)
        .then((name) {
      setState(() {
        locationName = name;
      });
    });
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      // print(placemarks);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // print(place);
        return "${place.street}"; // TODO
      }
      return "No location found";
    } catch (e, stacktrace) {
      print('Exception: $e\nStack Trace: $stacktrace $latitude $longitude');
      return "Failed to get location: ($latitude;$longitude)";
  }
}

String getTimeLeft(DateTime eventTime) {
  final now = DateTime.now();
  final difference = eventTime.difference(now);

  if (difference.isNegative) {
    if (difference.abs() < widget.event.parseDuration()) {
      return 'Event ocurring';
    }
    return 'Event has passed.';
  } else if (difference.inDays > 0) {
    return 'Starts in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}.';
  } else if (difference.inHours > 0) {
    return 'Starts in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}.';
  } else if (difference.inMinutes > 0) {
    return 'Starts in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}.';
  } else {
    return 'Starting soon.';
  }
}

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      if (widget.showDescription) return;
      if (!await FireStoreMethods().eventExists(widget.event)) {
        showErrorMessage(context, "Event not available anymore");
        widget.refreshEvents!();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: widget.event)),
        );
      }
    },
    child: Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity, // Maximum width
            height: 200.0, // Adjust height as needed
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ), // Set the border radius
              // Other decoration properties if needed
            ),

          clipBehavior: Clip.antiAlias, // This clips the image inside the container to the border radius
          child: 
          widget.event.urlImage.isEmpty
          ? SvgPicture.asset(
              'lib/assets/default_event_image.svg',
              width: 100.0,
              height: 200.0,
              fit: BoxFit.cover,
            )
          : Image.network(widget.event.urlImage,
              width: 100.0,
              height: 200.0,
              fit: BoxFit.cover,
              
              ),

        ),

          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text('${widget.event.enrolledUsers.length}'),
                    const SizedBox(width: 4.0),
                    const Icon(Icons.person_2_rounded, size: 22.0),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 2.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Text(
                        widget.event.locationName == "" ? "Event has no locationName yet" : widget.event.locationName,
                          textAlign: TextAlign.left,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        getTimeLeft(widget.event.time),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  if (widget.showDescription) const SizedBox(height: 10.0),
                  if (widget.showDescription)
                    Text(
                      widget.event.description,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}