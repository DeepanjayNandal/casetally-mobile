import 'package:flutter/cupertino.dart';
import '../../../components/app_text.dart';

class SearchErrorDisplay extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const SearchErrorDisplay({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          AppText.title(context, 'Something went wrong'),
          const SizedBox(height: 8),
          AppText.secondary(
            context,
            errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
