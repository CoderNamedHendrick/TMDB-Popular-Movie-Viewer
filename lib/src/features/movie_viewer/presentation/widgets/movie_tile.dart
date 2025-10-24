import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/shared.dart';

class MovieTile extends StatelessWidget {
  const MovieTile({super.key, this.leading, required this.title, this.onTap});

  final Widget? leading;
  final Widget title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        leading: leading,
        title: title,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: context.colorScheme.primary, height: 1),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class MovieTileShimmer extends StatelessWidget {
  const MovieTileShimmer({super.key});

  static Widget list = SingleChildScrollView(
    child: Column(children: List.generate(15, (_) => const MovieTileShimmer())),
  );

  @override
  Widget build(BuildContext context) {
    return const Skeletonizer(
      child: MovieTile(title: Text('Jurassic Hunt'), leading: CircleAvatar(radius: 20)),
    );
  }
}
