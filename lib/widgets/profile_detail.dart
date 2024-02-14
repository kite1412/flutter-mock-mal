import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/mal/user_information.dart';

class ProfileDetail extends StatelessWidget {
  const ProfileDetail({super.key, required this.userInfo});

  final UserInformation userInfo;

  final String editProfileUrl = "https://myanimelist.net/editprofile.php";
  final editPassOrNameUrl = "https://myanimelist.net/editprofile.php?go=myoptions";

  String _assertNull(String? word) {
    if (word == null) {
      return "Not Set";
    }
    return word;
  }

  String _capitalize(String? word) {
    if (word == null) {
      return "Not Set";
    }
    String firstLetter = word[0].toUpperCase();
    return firstLetter + word.substring(1, word.length);
  }

  String _formatDate(String? date) {
    if (date == null) {
      return "Not Set";
    }
    String formatted = DateFormat("dd-MMMM-yyyy").format(DateTime.parse(date));
    List<String> dmy = formatted.split("-");
    dmy[0].startsWith("0") ? dmy[0] = dmy[0].substring(1) : null;
    return dmy.join(" ");
  }

  Color _decideColor(String? field, BuildContext context) {
    Color color = Theme.of(context).textTheme.displaySmall!.color!;
    if (field == null || field == "Not Set" || field.isEmpty) {
      if (Theme.of(context).brightness == Brightness.light) {
        color = Colors.grey.shade600;
      } else {
        color = Colors.grey;
      }
    }
    return color;
  }

  Color _color(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ?
        Colors.grey.shade600 : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) =>
      Scaffold(
        appBar: AppBar(
            leadingWidth: constraint.maxWidth,
            leading: Row(
              children: [
                const SizedBox(width: 4,),
                GestureDetector(
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                Text("My Profile", style: Theme.of(context).textTheme.displayMedium,)
              ],
            )
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 36, left: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: "profile-pic",
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).textTheme.displaySmall!.color!),
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ClipOval(
                            child: Image(
                              image: Image.network(userInfo.picture).image,
                              height: 170,
                              width: 170,
                            ),
                          ),
                        )
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Username:", style: TextStyle(color: _color(context)),),
                            Text(
                              userInfo.name,
                              style: Theme.of(context).textTheme.displayLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8,),
                            Text("User id:", style: TextStyle(color: _color(context)),),
                            Text(userInfo.id.toString(), style: Theme.of(context).textTheme.displayMedium,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 32, color: _color(context)),
                          const SizedBox(width: 8,),
                          Text(
                            _capitalize(_assertNull(userInfo.gender)),
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(color: _decideColor(userInfo.gender, context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16,),
                      Row(
                        children: [
                          Icon(Icons.celebration_outlined, size: 32, color: _color(context),),
                          const SizedBox(width: 8,),
                          Text(
                            _formatDate(userInfo.birthday),
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(color: _decideColor(userInfo.birthday, context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16,),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 32, color: _color(context),),
                          const SizedBox(width: 8,),
                          Text(
                            _assertNull(userInfo.timeZone),
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(color: _decideColor(userInfo.location, context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16,),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 32, color: _color(context),),
                          const SizedBox(width: 8,),
                          Text(
                            _formatDate(userInfo.joinedAt),
                            style: Theme.of(context).textTheme.displaySmall!.copyWith(color: _decideColor(userInfo.birthday, context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 4,),
                          Text("(join date)", style: TextStyle(color: _color(context)),)
                        ],
                      ),
                      const SizedBox(height: 32,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Change Password or Username "),
                          GestureDetector(
                            onTap: () => launchUrl(Uri.parse(editPassOrNameUrl)),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.blue),
                                ),
                              ),
                              child: Text(
                                  "here",
                                  style: Theme.of(context)
                                      .textTheme.bodyMedium?.copyWith(
                                      color: Colors.blue,
                                      fontStyle: FontStyle.italic
                                  )
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloatingActionButton.extended(
                            heroTag: "edit-button",
                            backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                            onPressed: () => launchUrl(Uri.parse(editProfileUrl)),
                            label: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 32, color: Theme.of(context).colorScheme.primary,),
                                const SizedBox(width: 4,),
                                Text("Edit", style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).colorScheme.primary),),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16,),
                          FloatingActionButton.extended(
                            heroTag: "stats-button",
                            onPressed: () {},
                            label: Row(
                              children: [
                                const Icon(Icons.stacked_line_chart_outlined, size: 32, color: Colors.white),
                                const SizedBox(width: 4,),
                                Text("Statistic", style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.white),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}