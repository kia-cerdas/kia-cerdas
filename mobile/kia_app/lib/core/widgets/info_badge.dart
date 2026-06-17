// Sebagai info warning kecil di card data anak

import 'package:flutter/material.dart';

class InfoBadge extends StatelessWidget {
  final String text;
  final bool isWarning;

  const InfoBadge(this.text, {this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.info_outline : Icons.check_circle_outline,
            size: 14,
            color: isWarning ? Colors.orange : Colors.green,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isWarning ? Colors.orange : Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}