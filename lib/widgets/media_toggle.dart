import 'package:anime_gallery/notifier/global_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MediaToggle extends StatefulWidget {
  final void Function(int) onToggleChange;

  const MediaToggle({
    super.key,
    required this.onToggleChange
  });

  @override
  State<MediaToggle> createState() => _MediaToggleState();
}

class _MediaToggleState extends State<MediaToggle> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 197,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2
        ),
        borderRadius: const BorderRadius.all(Radius.circular(100)),
        color: Colors.transparent
      ),
      child: LayoutBuilder(builder: (context, constraint) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashFactory: InkSplash.splashFactory,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100)
                ),
                onTap: Provider.of<GlobalNotifier>(context).enableMediaToggleChange ? () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                  widget.onToggleChange(_selectedIndex);
                } : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(100),
                      bottomLeft: Radius.circular(100)
                    ),
                    color: _selectedIndex != 0 ? Colors.grey.shade700 : Theme.of(context).colorScheme.primary,
                  ),
                  height: constraint.maxHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  child: Text(
                    "Anime",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
            Align(
              child: Container(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
                onTap: Provider.of<GlobalNotifier>(context).enableMediaToggleChange ? () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  widget.onToggleChange(_selectedIndex);
                } : null,
                splashFactory: InkSplash.splashFactory,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100)
                      ),
                      color: _selectedIndex != 1 ? Colors.grey.shade700 : Theme.of(context).colorScheme.primary
                  ),
                  height: constraint.maxHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  child: Text(
                    "Manga",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white
                    ),
                  ),
                ),
              )
            )
          ],
        );
      })
    );
  }
}