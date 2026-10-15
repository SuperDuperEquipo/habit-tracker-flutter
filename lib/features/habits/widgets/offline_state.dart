import 'package:flutter/material.dart';
import 'package:rachas/core/config/app_strings.dart';
import 'package:rachas/core/errors/app_exception.dart';
import 'package:rachas/core/theme/theme_data.dart';
import 'package:rachas/core/widgets/primary_button.dart';

class OfflineState extends StatelessWidget {
  const OfflineState({super.key, required this.error, required this.onRetry});

  final AppException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isOffline = error.type == AppErrorType.noConnection;
    final secondary = AppTheme.slateBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.skyBlue.withValues(alpha: 0.3),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              isOffline ? Icons.wifi_off : Icons.cloud_off,
              size: 36,
              color: secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isOffline ? AppStrings.offlineTitle : AppStrings.loadErrorTitle,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppTheme.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOffline ? AppStrings.offlineBody : error.message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: secondary),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: AppStrings.retry,
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}