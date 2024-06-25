import "package:flutter/material.dart";

class TextBox extends StatelessWidget {
  final String text;
  final String section;
  final bool othersprofile;

  final void Function() onPressed;
  const TextBox({
    super.key,
    required this.text,
    required this.section,
    required this.onPressed,
    required this.othersprofile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: othersprofile
            ? [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0),
                  child: Text(section,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontFamily: 'Comfortaa',
                        fontSize: 16,
                      )),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0,left: 10.0,right: 10.0),
                  child: Text(
                    text,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ]
            : [
                Padding(
                  padding: const EdgeInsets.only(left:10.0, right: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(section,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontFamily: 'Comfortaa',
                            fontSize: 16,
                          )),
                      IconButton(
                        onPressed: onPressed,
                        icon: Icon(
                          Icons.edit,
                          size: 22,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:10.0,bottom: 10.0, right: 10.0),
                  child: Text(
                    text,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
      ),
    );
  }
}
