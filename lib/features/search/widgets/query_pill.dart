import 'package:flutter/cupertino.dart';

class QueryPill extends StatelessWidget {
  final String query;

  const QueryPill({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Text(
      query,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.white,
        letterSpacing: -0.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
