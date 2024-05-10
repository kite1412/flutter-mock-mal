import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchHistory extends StatelessWidget {
  final List<String> searchesHistory;
  final void Function(String) onTap;
  final void Function(String) onDelete;
  final VoidCallback onDeleteAll;

  const SearchHistory({
    super.key,
    required this.searchesHistory,
    required this.onTap,
    required this.onDelete,
    required this.onDeleteAll
  });

  List<Widget> _contents(BuildContext context) => [
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
              Colors.grey : Colors.grey.shade700
          )
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Recent Searches",
            style: Theme.of(context).textTheme.displaySmall
          ),
          GestureDetector(
            onTap: onDeleteAll,
            child: const Icon(CupertinoIcons.clear_circled),
          )
        ],
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return searchesHistory.isNotEmpty ? Column(
      children: _contents(context)..addAll(
        searchesHistory.map((string) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: _SearchHistoryBar(value: string, onTap: onTap, onDelete: onDelete,),
          );
        }).toList()
      ),
    ) : Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No History",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontStyle: FontStyle.italic
            ),
          )
        ],
      ),
    );
  }
}

class _SearchHistoryBar extends StatelessWidget {
  final String value;
  final void Function(String) onTap;
  final void Function(String) onDelete;

  const _SearchHistoryBar({
    required this.value,
    required this.onTap,
    required this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(value),
      child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.youtube_searched_for_rounded,
                color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                  Colors.grey.shade600 : Colors.grey.shade700,
              ),
              const SizedBox(width: 8,),
              Expanded(
                child: Text(
                  value, maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => onDelete(value),
                child: Icon(
                  CupertinoIcons.clear,
                  color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                    Colors.grey.shade600 : Colors.grey.shade700,
                ),
              )
            ],
          )
      ),
    );
  }
}
