import 'package:flutter/material.dart';

class PersonNode extends StatelessWidget {
  final String name;
  final String birthDate;
  final String deathDate;
  final String additionalInfo;

  const PersonNode({super.key, 
    required this.name,
    required this.birthDate,
    required this.deathDate,
    required this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show more details or perform an action
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(name),
            content: Text('More details about $name:\n$additionalInfo'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$birthDate - $deathDate'),
            Text(additionalInfo, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
