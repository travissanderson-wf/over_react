import 'dart:html';
import 'package:react/react_dom.dart' as react_dom;
import 'package:react/react_client.dart';

import '../demos.dart';
import '../constants.dart';

main() {
  setClientConfiguration();

  react_dom.render(alertBasicDemo(),
      querySelector('$demoMountNodeSelectorPrefix--alert-basic'));

  react_dom.render(alertDismissibleDemo(),
      querySelector('$demoMountNodeSelectorPrefix--alert-dismissible'));
}
