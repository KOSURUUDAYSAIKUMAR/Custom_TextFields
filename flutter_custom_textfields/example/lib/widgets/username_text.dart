import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

class UsernameText extends StatefulWidget {
  final TextEditingController usernameController;
  final FocusNode usernameNode;

  const UsernameText({
    super.key,
    required this.usernameController,
    required this.usernameNode,
  });

  @override
  State<UsernameText> createState() => _UsernameTextState();
}

class _UsernameTextState extends State<UsernameText> {
  @override
  void initState() {
    super.initState();
    // Add a listener to the controller to print its text on every change
    widget.usernameController.addListener(_onUsernameChanged);
  }

  void _onUsernameChanged() {
    // This will print every time the controller's text changes
    print("Controller text updated: ${widget.usernameController.text}");
    // If you needed to rebuild _UsernameTextState based on this change, you'd call setState here,
    // but for just printing, it's not necessary.
    // setState(() {});
  }

  @override
  void dispose() {
    // Remove the listener to prevent memory leaks
    widget.usernameController.removeListener(_onUsernameChanged);
    widget.usernameController.dispose();
    widget.usernameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This print will only show when _UsernameTextState.build is called
    print(
      "UsernameTextfield build called, controller text: ${widget.usernameController.text}",
    );

    return UsernameTextfield(
      hint: "Enter your username",
      validationPattern: RegExp('^[a-zA-Z0-9@_#]{3,10}\$'),
      inputFormatterPattern: RegExp('^[a-zA-Z0-9@_#]'),
      controller: widget.usernameController,
      focusNode: widget.usernameNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      invalidUsernameMessage:
          'Username must be 3-10 characters and can only contain letters, numbers, and @, _, or #',
      preventLeadingTrailingSpaces: false,
      preventConsecutiveSpaces: false,
      useInputFormatter: true,
    );
  }
}
