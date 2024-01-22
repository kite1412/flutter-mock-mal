import 'package:anime_gallery/model/user_information.dart';
import 'package:anime_gallery/widgets/profile_detail.dart';
import 'package:flutter/material.dart';

class ProfileDetailBar extends StatefulWidget {
  const ProfileDetailBar({super.key, required this.emptySpaceTappedCallback, required this.userInfo});
  final VoidCallback emptySpaceTappedCallback;
  final UserInformation userInfo;

  @override
  State<ProfileDetailBar> createState() => _ProfileDetailBarState();
}

class _ProfileDetailBarState extends State<ProfileDetailBar> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _profilePicSizeAnimation;
  late Animation<double> _containerSizeAnimation;
  late double? _containerHeight;
  UserInformation userInfo = UserInformation.empty();

  void _fetchProfileDetail() {
    setState(() {
      userInfo = widget.userInfo;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileDetail();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _profilePicSizeAnimation = Tween<double>(begin: 40.0, end: 100.0)
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      _containerHeight = constraint.maxHeight / 2.5;
      _containerSizeAnimation = Tween(begin: 100.0, end: _containerHeight).animate(_animationController);
      _animationController.forward();
      return Column(
        children: [
          AnimatedBuilder(
            animation: _containerSizeAnimation,
            builder: (BuildContext context, Widget? child) {
              return Container(
                  width: constraint.maxWidth,
                  height: _containerSizeAnimation.value,
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4, left: 8, bottom: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              onPressed: widget.emptySpaceTappedCallback,
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white,),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, right: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            userInfo.name,
                                            style: Theme.of(context).textTheme.displaySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8,),
                                          // TODO to edit profile page
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (context) {
                                                  return ProfileDetail(userInfo: userInfo);
                                                }),
                                              );
                                            },
                                            child: const Text(
                                              "Edit Profile",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontStyle: FontStyle.italic
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _profilePicSizeAnimation,
                                    builder: (context, child) {
                                      return Hero(
                                        tag: "profile-pic",
                                        child: ClipOval(
                                          child: Image(
                                            height: _profilePicSizeAnimation.value,
                                            width: _profilePicSizeAnimation.value,
                                            image: Image.network(userInfo.picture).image,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
              );
            }
          ),
          Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.emptySpaceTappedCallback,
                child: Container(),
              )
          )
        ],
      );
    });
  }
}