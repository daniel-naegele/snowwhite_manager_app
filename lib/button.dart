import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const Button({Key key, @required this.onTap, this.child}) : super(key: key);

  Button.text({Key key, VoidCallback onTap, String text})
      : this(
          key: key,
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(32)),
              color: Theme.of(context).primaryColor),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
