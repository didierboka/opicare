import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';

class NotifCard extends StatelessWidget {
  const NotifCard({super.key, required this.sms});
  final Map<String, String> sms;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colours.background,
        border: Border.all(color: Colours.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colours.primaryBlue.withOpacity(0.1),
            radius: 20,
            child: const Icon(
              Icons.mail_outline,
              color: Colours.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sms['message'] ?? '',
                  style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text('Date de reception: ${sms['date']}', style: TextStyles.caption.copyWith(color: Colours.primaryBlue)),
              ],
            ),
          )
        ],
      ),
    );;
  }
}
