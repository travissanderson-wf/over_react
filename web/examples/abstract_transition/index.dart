library over_react.web.examples.abstract_transition;

import 'dart:html';

import 'package:over_react/over_react.dart';
import 'package:platform_detect/decorator.dart';
import 'package:react/react_dom.dart' as react_dom;

import '../../src/demo_components.dart';

void main() {
  decorateRootNodeWithPlatformClasses();
  setClientConfiguration();

  react_dom.render(AbstractTransitionExample()(), querySelector('#example-container'));
}

@Factory()
UiFactory<AbstractTransitionExampleProps> AbstractTransitionExample;

@Props()
class AbstractTransitionExampleProps extends UiProps {}

@State()
class AbstractTransitionExampleState extends AbstractTransitionState {
  bool alertIsMounted;
}

@Component()
class AbstractTransitionExampleComponent extends UiStatefulComponent<AbstractTransitionExampleProps, AbstractTransitionExampleState> {
  AlertComponent alertComponent;

  /// Whether the [AbstractTransitionComponent] is hidden or in the process of hiding.
  bool get isOrWillBeHidden =>
      state.transitionPhase == TransitionPhase.HIDING ||
      state.transitionPhase == TransitionPhase.HIDDEN;

  /// Whether the [AbstractTransitionComponent] is shown or in the process of showing.
  bool get isOrWillBeShown =>
      state.transitionPhase == TransitionPhase.PRE_SHOWING ||
      state.transitionPhase == TransitionPhase.SHOWING ||
      state.transitionPhase == TransitionPhase.SHOWN;

  @override
  getInitialState() => (newState()
    ..transitionPhase = TransitionPhase.HIDDEN
    ..alertIsMounted = true
  );

  ReactElement get alert => state.alertIsMounted ? _renderAlert() : Dom.div()('unmounted');

  @override
  render() {
    return (Dom.div()..className = 'p-3')(
      (Dom.div()
        ..style = {'height': '5rem'}
      )(
        alert
      ),
      (Dom.div()..className = 'd-flex')(
        (ButtonGroup()..className = 'pr-1')(
          (Button()
            ..isDisabled = isOrWillBeShown
            ..onClick = (_) {
              if (!state.alertIsMounted) {
                setState(newState()..alertIsMounted = true, () {
                  alertComponent.show();
                });
              } else {
                alertComponent.show();
              }
            }
          )('show'),
          (Button()
            ..isDisabled =  isOrWillBeHidden
            ..onClick = (_) { alertComponent.hide(); }
          )('hide'),
          (Button()
            ..isDisabled = !state.alertIsMounted
            ..onClick = (_) {
              alertComponent.hide();
              setState(newState()..alertIsMounted = false);
            }
          )('unmount'),
        ),
        (Dom.div()..style = {'display': 'inline-block'})(
          (Dom.pre()..className = 'mb-0')(
            'state.transitionPhase: ${state.transitionPhase}'
          ),
        ),
      ),
    );
  }

  ReactElement _renderAlert() {
    return (Alert()
      ..skin = AlertSkin.WARNING
      ..isDismissible = true
      ..initiallyShown = false
      ..onWillShow = () { setState(newState()..transitionPhase = TransitionPhase.SHOWING); }
      ..onDidShow = () { setState(newState()..transitionPhase = TransitionPhase.SHOWN); }
      ..onWillHide = () { setState(newState()..transitionPhase = TransitionPhase.HIDING); }
      ..onDidHide = () { setState(newState()..transitionPhase = TransitionPhase.HIDDEN); }
      ..ref = (instance) { alertComponent = instance; }
    )(
      Dom.strong()('Holy guacamole!'),
      ' You should check in on some of those fields below.',
    );
  }
}
