import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const MenuTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withAlpha(110),
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(15) : Radius.zero,
            bottom: isLast ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(15) : Radius.zero,
              topRight: isFirst ? const Radius.circular(15) : Radius.zero,
              bottomLeft: isLast ? const Radius.circular(15) : Radius.zero,
              bottomRight: isLast ? const Radius.circular(15) : Radius.zero,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 30,
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withAlpha(128),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
