import 'package:flutter/material.dart';

showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Please enter a name'),
              const TextField(
                decoration: InputDecoration(
                  // border: InputBorder.none,
                  hintText: 'Username',
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    40,
                  ),
                ),
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
