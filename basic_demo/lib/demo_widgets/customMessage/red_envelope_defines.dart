part of 'red_envelope.dart';

enum DemoCustomMessageType {
  redEnvelope,
}

ButtonStyle sendRedEnvelopeButtonStyle() {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.redAccent),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    shape: MaterialStateProperty.all(
      const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
    ),
  );
}
