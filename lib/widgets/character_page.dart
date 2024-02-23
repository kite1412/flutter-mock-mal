import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/jikan/character.dart';

class CharacterPage extends StatelessWidget {
  final List<Character> characters;
  final VoidCallback onPop;

  const CharacterPage({
    super.key,
    required this.characters,
    required this.onPop
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: Row(
              children: [
                IconButton(
                  onPressed: onPop,
                  icon: const Icon(Icons.arrow_back_rounded)
                ),
                const SizedBox(width: 8,),
                Text(
                  "Characters",
                  style: Theme.of(context).textTheme.displaySmall,
                )
              ],
            ),
            leadingWidth: double.infinity,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            sliver: SliverList.separated(
              itemBuilder: (context, index) => _CharacterCard(character: characters[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 6,),
              itemCount: characters.length,
            )
          )
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;

  const _CharacterCard({
    required this.character
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        children: [
          Image.network(
            character.character!.images!.jpg?.imageUrl ?? "https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg",
            height: 140,
            width: 110,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.character!.name!,
                    style: Theme.of(context).textTheme.displaySmall,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    character.role!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: MediaQuery.platformBrightnessOf(context) == Brightness.light ?
                        Colors.grey.shade600 : Colors.grey
                    ),
                  )
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}