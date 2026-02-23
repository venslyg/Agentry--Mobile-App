import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/housemaid.dart';
import '../models/maid_status.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class MaidListTile extends ConsumerWidget {
  final Housemaid maid;
  final double remaining;
  final VoidCallback onTap;

  const MaidListTile({
    super.key,
    required this.maid,
    required this.remaining,
    required this.onTap,
  });

  Color _statusColor(BuildContext context) {
    switch (maid.status) {
      case MaidStatus.atAgency:
        return AppColors.atAgency;
      case MaidStatus.sentAbroad:
        return AppColors.sentAbroad;
      case MaidStatus.completed:
        return AppColors.completed;
    }
  }

  bool get _isFullyPaid => remaining <= 0.001;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final statusColor = _statusColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: _isFullyPaid
            ? Border.all(color: AppColors.green.withValues(alpha: 0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Text(
            maid.name.isNotEmpty ? maid.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                maid.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            if (_isFullyPaid)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.green, size: 12),
                    SizedBox(width: 3),
                    Text('Fully Paid',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Passport: ${maid.passportId}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                maid.status.label,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Balance',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[500])),
            Text(
              '$symbol${remaining.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _isFullyPaid ? AppColors.green : AppColors.orange,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
