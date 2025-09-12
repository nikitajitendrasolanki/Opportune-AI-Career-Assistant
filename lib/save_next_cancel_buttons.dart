import 'package:flutter/material.dart';

class SaveNextCancelButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onCancel;
  final String nextText;
  final String cancelText;

  const SaveNextCancelButtons({
    Key? key,
    required this.onNext,
    required this.onCancel,
    this.nextText = "Save & Next",
    this.cancelText = "Cancel",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.close, color: Colors.white),
          label: Text(
            cancelText,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          label: Text(
            nextText,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
