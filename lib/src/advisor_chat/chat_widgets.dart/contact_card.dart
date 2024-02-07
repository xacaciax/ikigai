import 'package:flutter/material.dart';

class ContactCardButton extends StatelessWidget {
  final String contactName;
  final String contactProfession;
  final VoidCallback onTap;

  const ContactCardButton({
    Key? key,
    required this.contactName,
    required this.contactProfession,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade200,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(contactName),
          subtitle: Text(contactProfession),
          trailing: Icon(Icons.info_outline, color: Colors.blue),
        ),
      ),
    );
  }
}
