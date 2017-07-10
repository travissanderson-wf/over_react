library over_react.web.examples.resize_sensor;

import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:platform_detect/decorator.dart';
import 'package:react/react_dom.dart' as react_dom;

import '../../src/demo_components.dart';

void main() {
  decorateRootNodeWithPlatformClasses();
  setClientConfiguration();

  react_dom.render(ResizeSensorExample()(), querySelector('#example-container'));
}

@Factory()
UiFactory<ResizeSensorExampleProps> ResizeSensorExample;

@Props()
class ResizeSensorExampleProps extends UiProps {}

@State()
class ResizeSensorExampleState extends UiState {
  /// Default: false
  bool isManuallyResized;

  /// Stores the most recent value of [ResizeSensorEvent.newWidth] from [ResizeSensorExampleComponent._handleResize].
  int width;

  /// Stores the most recent value of [ResizeSensorEvent.newHeight] from [ResizeSensorExampleComponent._handleResize].
  int height;

  /// Stores the most recent value of [ResizeSensorEvent.prevWidth] from [ResizeSensorExampleComponent._handleResize].
  int prevWidth;

  /// Stores the most recent value of [ResizeSensorEvent.prevHeight] from [ResizeSensorExampleComponent._handleResize].
  int prevHeight;
}

@Component()
class ResizeSensorExampleComponent extends UiStatefulComponent<ResizeSensorExampleProps, ResizeSensorExampleState> {
  @override
  getInitialState() => (newState()..isManuallyResized = false);

  @override
  render() {
    // Render the ResizeSensor inside a div styled to match the dimensions of the window,
    // so that resizing the window triggers the sensor.
    return (Dom.div()
      ..style = {
        'width': '100%',
        'height': '100vh'
      }
    )(
      (ResizeSensor()
        ..onResize = _handleResize
        ..onInitialize = _handleResize
        ..isFlexContainer = true
      )(
        (Dom.div()
          ..className = 'card card-outline-success'
          ..style = {
            'display': 'flex',
            'flexDirection': 'column',
            'width': '100%',
            'height': '100vh',
          }
        )(
          (Dom.div()
            ..className = 'card-block'
            ..style = {'flex': '1 1 0%'}
          )(
            (Dom.h4()..className = 'card-title')('ResizeSensor'),
            (Dom.p()..className = 'card-text')('Resize the viewport to see the ResizeSensor in action!'),
            _renderSensorOutput(),
          ),
        ),
      ),
    );
  }

  ReactElement _renderSensorOutput() {
    return (Dom.pre()..className = 'text-primary')(
      'Width: ${state.width}\n',
      'Height: ${state.height}\n\n',
      'Previous Width: ${state.prevWidth}\n',
      'Previous Height: ${state.prevHeight}',
    );
  }

  void _handleResize(ResizeSensorEvent event) {
    setState(newState()
      ..width = event.newWidth
      ..height = event.newHeight
      ..prevWidth = event.prevWidth
      ..prevHeight = event.prevHeight
    );
  }
}
