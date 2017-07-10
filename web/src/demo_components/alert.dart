part of over_react.web.demo_components;

/// Use the Alert component to provide contextual feedback messages for
/// typical user actions with the handful of available and flexible alert messages.
///
/// > See: <http://v4-alpha.getbootstrap.com/components/alert/>
@Factory()
UiFactory<AlertProps> Alert;

@Props()
class AlertProps extends AbstractTransitionProps {
  /// The skin of the [Alert].
  ///
  /// Use any of the available [AlertSkin] options to change the colors of an [Alert].
  ///
  /// > See: <https://v4-alpha.getbootstrap.com/components/alerts/#examples>
  ///
  /// __REQUIRED.__
  @requiredProp
  AlertSkin skin;

  /// Whether the [Alert] can be manually dismissed when the user clicks the [Alert]'s "dismiss" [Button].
  ///
  /// > See: <https://v4-alpha.getbootstrap.com/components/alerts/#dismissing>
  ///
  /// Default: `false`
  bool isDismissible;

  /// The optional heading for the [Alert].
  ///
  /// When an [Alert] has a lengthy message, use a [heading] to help break up the content.
  ///
  /// > See: <https://v4-alpha.getbootstrap.com/components/alerts/#additional-content>
  dynamic heading;

  /// Props map for the optional Alert [heading].
  ///
  /// Example usage:
  ///
  ///     (Alert()
  ///       ..headingProps = (domProps()
  ///         ..className = 'custom-alert-heading-class
  ///         ..title = 'Add more information here.'
  ///       )
  ///     )()
  Map headingProps;

  /// A callback for when the user clicks the dismiss button.
  DomEventCallback onDismissButtonClick;

  /// Whether the [Alert] should be visible initially when mounted.
  ///
  /// Default: `true`
  bool initiallyShown;

  /// The optional amount of time, in milliseconds, that the [Alert] will remain visible after it first appears.
  ///
  /// If not set, the [Alert] will remain visible indefinitely until the user dismisses it, or it is manually dismissed
  /// via the [AbstractTransitionComponent.hide] method.
  int dismissAfter;

  /// The type of CSS transition that will be used when the [Alert] appears / disappears.
  ///
  /// Default: [AlertTransition.FADE]
  AlertTransition transition;
}

@State()
class AlertState extends AbstractTransitionState {}

@Component()
class AlertComponent extends AbstractTransitionComponent<AlertProps, AlertState> {
  @override
  bool get initiallyShown => props.initiallyShown;

  @override
  Element getTransitionDomNode() => findDomNode(this);

  @override
  bool get hasTransition => props.transition != null && props.transition != AlertTransition.NONE;

  @override
  Map getDefaultProps() => (newProps()
    ..addAll(super.getDefaultProps())
    ..isDismissible = false
    ..transition = AlertTransition.FADE
    ..initiallyShown = true
  );

  @override
  get consumedProps => const [
    const $Props(AlertProps),
    const $Props(AbstractTransitionProps),
    const $Props(TransitionPropsMixin),
  ];

  // --------------------------------------------------------------------------
  // Component Lifecycle
  // --------------------------------------------------------------------------

  @override
  void componentDidMount() {
    _bindBlurHandlers();
    _bindFocusHandlers();
    _bindMouseDownHandlers();

    if (state.transitionPhase == TransitionPhase.SHOWN) {
      _initializeDismissTimer();
    }
  }

  @override
  void componentWillUnmount() {
    super.componentWillUnmount();
    _unbindFocusHandlers();
    _unbindBlurHandlers();
    _unbindMouseDownHandlers();
    _cancelDismissTimer();
  }

  // --------------------------------------------------------------------------
  // Component Rendering
  // --------------------------------------------------------------------------

  @override
  render() {
    var classes = forwardingClassNameBuilder()
      ..add('alert')
      ..add(props.skin.className)
      ..add('alert-dismissible', props.isDismissible)
      ..add(props.transition.className)
      ..add('in', isShown);

    return (Dom.div()
      ..addProps(copyUnconsumedDomProps())
      ..addProps(ariaProps()..live = props.skin.tone)
      ..className = classes.toClassName()
      ..role = Role.alert
    )(
      _renderHeading(),
      _renderDismissButton(),
      props.children,
    );
  }

  ReactElement _renderDismissButton() {
    if (!props.isDismissible) return null;

    return (Button()
      ..className = 'close'
      ..classNameBlacklist = 'btn btn-primary'
      ..onClick = _handleDismissButtonClick
      ..addProps(ariaProps()..label = 'Close')
    )(
      (Dom.span()..addProps(ariaProps()..hidden = true))('\u00d7'),
    );
  }

  ReactElement _renderHeading() {
    if (props.heading == null) return null;

    var classes = new ClassNameBuilder.fromProps(props.headingProps)
        ..add('alert-heading');

    return (Dom.h4()
      ..addProps(props.headingProps)
      ..className = classes.toClassName()
    )(props.heading);
  }

  // --------------------------------------------------------------------------
  // Event Handlers
  // --------------------------------------------------------------------------

  _handleDismissButtonClick(SyntheticEvent event) {
    if (props.onDismissButtonClick != null && props.onDismissButtonClick(event) == false) {
      return;
    }

    hide();
  }

  // --------------------------------------------------------------------------
  // Private Utilities
  // --------------------------------------------------------------------------

  /// Timer used to delay the automatic dismiss of the [Alert].
  Timer _dismissTimer;

  /// Timer used to check if [Alert] is focused after a `blur` event.
  Timer _blurTimer;

  /// Stream for listening to `focus` events on the document.
  StreamSubscription _onDocumentFocusListener;

  /// Stream for listening to `blur` events on the document.
  StreamSubscription _onDocumentBlurListener;

  /// Stream for listening to `mousedown` events on the document.
  StreamSubscription _onDocumentMouseDownListener;

  /// Element that was focused (`document.activeElement`) before the [Alert] was dismissed.
  Element _previouslyFocusedElement;

  /// Whether a `mousedown` event has occurred within the [Alert].
  bool _hasMousedDownInOrOnAlert = false;

  /// Starts a timer that will automatically dismiss the [Alert]
  /// if [AlertProps.dismissAfter] is set.
  ///
  /// Normally uses `new Timer`, but can be used to DI mock timers during testing.
  void _initializeDismissTimer() {
    var testTimerFactory = props['_testTimerFactory'];

    if (props.dismissAfter == null) {
      return;
    }

    _dismissTimer?.cancel();

    var duration = new Duration(milliseconds: props.dismissAfter);
    var callback = () {
      hide();
    };

    _dismissTimer = testTimerFactory != null
        ? testTimerFactory(duration, callback)
        : new Timer(duration, callback);
  }

  /// Tears down the timer started by [_initializeDismissTimer].
  void _cancelDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
  }

  /// Tears down the timer that would null [_previouslyFocusedElement].
  void _cancelBlurTimer() {
    _blurTimer?.cancel();
    _blurTimer = null;
  }

  // --------------------------------------------------------------------------
  // DOM Methods
  // --------------------------------------------------------------------------

  /// Captures the element that was focused (`document.activeElement`) when the
  /// click of the [CloseButton] within the [Alert] caused it to be blurred.
  ///
  /// This is to return focus to that element after the [Alert]
  /// is dismissed to avoid document freakout mode.
  void _bindFocusHandlers() {
    _onDocumentFocusListener = Element.focusEvent.forTarget(document, useCapture: true).listen((Event event) {
      _cancelBlurTimer();
      if (isOrContains(findDomNode(this), event.target)) {
        return;
      }

      _previouslyFocusedElement = event.target;
    });
  }

  /// Nulls the [_previouslyFocusedElement] on blur events if new a element
  /// does not become focused.
  ///
  /// This is to handle the case where the [_previouslyFocusedElement] is blurred
  /// before the [Alert] is dismissed manually.
  void _bindBlurHandlers() {
    _onDocumentBlurListener = Element.blurEvent.forTarget(document, useCapture: true).listen((Event event) {
      _cancelBlurTimer();
      if (isOrContains(findDomNode(this), event.target)) {
        return;
      }

      // Only start the timer if the blur event was not caused by a mouseDown in the Alert.
      if (!_hasMousedDownInOrOnAlert) {
        _blurTimer = new Timer(new Duration(milliseconds: blurTimerWait), () {
          _previouslyFocusedElement = null;
        });
      }
    });
  }

  /// Listens to `mousedown` events. Will either null the [_previouslyFocusedElement]
  /// or stop the [_onDocumentBlurListener] from nulling the [_previouslyFocusedElement].
  ///
  /// This handles two cases:
  /// > A `mousedown` occurs within or on the [Alert] and then manually dismissed.
  /// >> Handled by stopping the [_onDocumentBlurListener] from nulling the [_previouslyFocusedElement].
  ///
  /// > A `mousedown` occurs outside of the [Alert] when there is no active element.
  /// >> Handled by nulling the [_previouslyFocusedElement].
  void _bindMouseDownHandlers() {
    _onDocumentMouseDownListener = document.onMouseDown.listen((MouseEvent event) {
      if (isOrContains(findDomNode(this), event.target)) {
        _hasMousedDownInOrOnAlert = true;
        return;
      }

      if (getActiveElement() == null) {
        _previouslyFocusedElement = null;
      }

      _hasMousedDownInOrOnAlert = false;
    });
  }

  /// Cancels the focus event listener created by [_bindFocusHandlers].
  void _unbindFocusHandlers() {
    _onDocumentFocusListener?.cancel();
    _onDocumentFocusListener = null;
  }

  /// Cancels the blur event listener created by [_bindBlurHandlers].
  void _unbindBlurHandlers() {
    _onDocumentBlurListener?.cancel();
    _onDocumentBlurListener = null;
  }

  void _unbindMouseDownHandlers() {
    _onDocumentMouseDownListener?.cancel();
    _onDocumentMouseDownListener = null;
  }

  static const int blurTimerWait = 10;

  // --------------------------------------------------------------------------
  // State Transition Methods
  // --------------------------------------------------------------------------

  @override
  void prepareShow() {
    super.prepareShow();

    _cancelDismissTimer();
  }

  @override
  void prepareHide() {
    super.prepareHide();

    _cancelDismissTimer();
  }

  @override
  void handleHiding() {
    super.handleHiding();

    _previouslyFocusedElement?.focus();
  }

  @override
  void handleShown() {
    super.handleShown();

    _initializeDismissTimer();
  }
}

/// Skin options for an [Alert]
class AlertSkin extends ClassNameConstant {
  final String tone;

  const AlertSkin._(String name, String className, this.tone) : super(name, className);

  static const AlertSkin INFO     = const AlertSkin._('INFO', 'alert-info', 'polite');
  static const AlertSkin SUCCESS  = const AlertSkin._('SUCCESS', 'alert-success', 'polite');
  static const AlertSkin WARNING  = const AlertSkin._('WARNING', 'alert-warning', 'assertive');
  static const AlertSkin DANGER   = const AlertSkin._('DANGER', 'alert-danger', 'assertive');

  @override
  String get debugDescription => 'className: $className, tone: $tone';
}

class AlertTransition extends ClassNameConstant {
  const AlertTransition._(String name, String className) : super(name, className);

  /// The [Alert] will appear / disappear with no CSS transition.
  ///
  /// [className] value: null
  static const AlertTransition NONE = const AlertTransition._('NONE', null);

  /// The [Alert] will fade in / fade out using a CSS transition.
  ///
  /// [className] value: 'fade'
  static const AlertTransition FADE = const AlertTransition._('FADE', 'fade');
}
