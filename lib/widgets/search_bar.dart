
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/debounce.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  final int debounceTimeInMilli;
  final bool canPop;
  final VoidCallback onTap;
  final void Function(String) onChange;
  final void Function(String) onSubmitted;
  final void Function(bool) onPopInvoked;
  final VoidCallback onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isClearButtonVisible;
  // whether to use debounce effect on [onChange]
  final bool? needDebounce;

  const SearchBar({
    super.key,
    required this.debounceTimeInMilli,
    required this.canPop,
    required this.onTap,
    required this.onChange,
    required this.onSubmitted,
    required this.onClear,
    required this.onPopInvoked,
    this.controller,
    this.focusNode,
    required this.isClearButtonVisible,
    this.needDebounce,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(46);
}

class _SearchBarState extends State<SearchBar> {
  late final Debounce _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce(durationInMilli: widget.debounceTimeInMilli);
  }

  @override
  void dispose() {
    super.dispose();
    _debounce.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16, bottom: 2),
      width: widget.preferredSize.width,
      height: widget.preferredSize.height,
      child: Card(
        color: Colors.black54,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 6, bottom: 6, right: 4),
              child: Icon(CupertinoIcons.search, color: Colors.white),
            ),
            const SizedBox(width: 6,),
            Expanded(
              child: PopScope(
                canPop: widget.canPop,
                onPopInvoked: widget.onPopInvoked,
                child: TextField(
                  focusNode: widget.focusNode,
                  controller: widget.controller,
                  onTap: () {
                    widget.onTap();
                  },
                  onChanged: (string) {
                    if (widget.needDebounce != null && widget.needDebounce!) {
                      _debounce.call(() {
                        widget.onChange(string);
                      });
                    } else {
                      widget.onChange(string);
                    }
                  },
                  maxLines: 1,
                  onSubmitted: widget.onSubmitted,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                    labelText: "Search by title",
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    isCollapsed: true
                  ),
                ),
              ),
            ),
            widget.isClearButtonVisible ? IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.clear, color: Colors.white,)
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}