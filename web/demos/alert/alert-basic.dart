part of over_react.web.demos;

ReactElement alertBasicDemo() =>
  (Alert()..skin = AlertSkin.WARNING)(
    Dom.strong()('Holy guacamole!'),
    ' You should check in on some of those fields below.'
  );
