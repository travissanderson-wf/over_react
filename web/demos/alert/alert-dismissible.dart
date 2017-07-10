part of over_react.web.demos;

ReactElement alertDismissibleDemo() =>
  (Alert()
    ..skin = AlertSkin.WARNING
    ..isDismissible = true
  )(
    Dom.strong()('Holy guacamole!'),
    ' You should check in on some of those fields below.'
  );
