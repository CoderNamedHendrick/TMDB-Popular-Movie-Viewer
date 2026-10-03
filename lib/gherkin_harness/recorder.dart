import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const gherkinRecordingEnabled =
    kDebugMode && bool.fromEnvironment('INTEGRATION_TEST') && bool.fromEnvironment('GHERKIN_RECORD');

/// Capture policy is deny-by-default. Only reviewed public fields log literal text.
class GherkinRecorder {
  GherkinRecorder({this.actor = 'default', this.publicTextKeys = const {}, this.sensitiveKeys = const {}, this.sink});
  final String actor;
  final Set<String> publicTextKeys;
  final Set<String> sensitiveKeys;
  final void Function(String)? sink;
  final String session = DateTime.now().microsecondsSinceEpoch.toString();
  int _sequence = 0;
  String? route;
  bool sensitive(String? key) =>
      key == null ||
      !publicTextKeys.contains(key) ||
      sensitiveKeys.contains(key) ||
      RegExp(
        r'password|passwd|secret|otp|one.?time|verification.?code|card|cvv|cvc|pin|token',
        caseSensitive: false,
      ).hasMatch(key);
  void emit(String action, Map<String, Object?> fields) {
    if (!gherkinRecordingEnabled) return;
    final line =
        '[GHERKIN_REC] ${jsonEncode({'session': session, 'seq': _sequence++, 'timestamp': DateTime.now().toUtc().toIso8601String(), 'actor': actor, 'action': action, 'route': route, ...fields})}';
    (sink ?? debugPrintSynchronously)(line);
  }

  void text(String? key, String value, {bool protected = false}) {
    final redact = protected || sensitive(key);
    final id = (key ?? 'unkeyed_field').replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    emit('enter_text', {'key': key, 'value': redact ? '\${fixture:$id}' : value, 'sensitive': redact});
  }

  // Use a stable route name, never a URI containing tokens/user data.
  void navigation(String? stableRoute) {
    route = stableRoute?.split('?').first;
    emit('nav', {});
  }

  void fixture(String id, {String? interaction}) => emit('fixture', {'id': id, 'interaction': interaction});
  void scrollTo(String key) => emit('scroll_to', {'key': key});
}

class GherkinNavigatorObserver extends NavigatorObserver {
  GherkinNavigatorObserver(this.recorder);
  final GherkinRecorder recorder;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => recorder.navigation(route.settings.name);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => recorder.navigation(previousRoute?.settings.name);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => recorder.navigation(newRoute?.settings.name);
}

/// Attach around the app root. Global pointer observation does not compete for gestures.
/// Debug hit-test metadata is unavailable in profile; recording is debug-only.
class GherkinRecordingHarness extends StatefulWidget {
  const GherkinRecordingHarness({super.key, required this.recorder, required this.child});
  final GherkinRecorder recorder;
  final Widget child;
  @override
  State<GherkinRecordingHarness> createState() => _HarnessState();
}

class _HarnessState extends State<GherkinRecordingHarness> {
  final Map<int, ({Offset position, Map<String, Object?> target})> _pointers = {};
  TextEditingController? _controller;
  EditableText? _editable;
  String? _key;
  String? _last;
  bool _multitouch = false;
  @override
  void initState() {
    super.initState();
    if (!gherkinRecordingEnabled) return;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_pointer);
    FocusManager.instance.addListener(_focus);
  }

  @override
  void dispose() {
    if (gherkinRecordingEnabled) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_pointer);
      FocusManager.instance.removeListener(_focus);
      _controller?.removeListener(_changed);
    }
    super.dispose();
  }

  String? _nearestKey(Element element) {
    String? result;
    bool visit(Element e) {
      if (e.widget.key case ValueKey<String>(:final value)) {
        result = value;
        return false;
      }
      return true;
    }

    if (visit(element)) element.visitAncestorElements(visit);
    return result;
  }

  Map<String, Object?> _target(PointerEvent event) {
    final hits = HitTestResult();
    WidgetsBinding.instance.hitTestInView(hits, event.position, event.viewId);
    Element? element;
    for (final hit in hits.path) {
      if (hit.target case RenderObject(:final debugCreator)) {
        if (debugCreator is DebugCreator) {
          element = debugCreator.element;
          break;
        }
      }
    }
    if (element == null) {
      return {'x': event.position.dx, 'y': event.position.dy};
    }
    final key = _nearestKey(element);
    // Avoid collecting any field display value or arbitrary rendered text.
    // Public labels are opt-in through keys; all other unkeyed actions are gaps.
    String? label;
    if (key != null && !widget.recorder.sensitive(key)) {
      void visit(Element e) {
        if (e.widget is EditableText) return;
        if (e.widget case Text(:final data)) {
          label ??= data;
          return;
        }
        e.visitChildren(visit);
      }

      visit(element);
    }
    return {
      'key': key,
      'text': label,
      'publicText': label != null,
      'type': element.widget.runtimeType.toString(),
      'x': event.position.dx,
      'y': event.position.dy,
    };
  }

  void _pointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      if (_pointers.isNotEmpty) _multitouch = true;
      _pointers[event.pointer] = (position: event.position, target: _target(event));
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      final down = _pointers.remove(event.pointer);
      if (!_multitouch && event is PointerUpEvent && down != null) {
        if ((event.position - down.position).distance <= 12) {
          widget.recorder.emit('tap', down.target);
        } else {
          widget.recorder.emit('gesture_gap', {'type': 'drag', 'x': event.position.dx, 'y': event.position.dy});
        }
      }
      if (_pointers.isEmpty) _multitouch = false;
    }
  }

  void _focus() {
    final context = FocusManager.instance.primaryFocus?.context;
    Element? found;
    void visit(Element e) {
      if (found != null) return;
      if (e.widget is EditableText) {
        found = e;
        return;
      }
      e.visitChildren(visit);
    }

    if (context is Element) {
      visit(context);
      if (found == null) {
        context.visitAncestorElements((e) {
          if (e.widget is EditableText) {
            found = e;
            return false;
          }
          return true;
        });
      }
    }
    final next = found?.widget as EditableText?;
    if (identical(next?.controller, _controller)) return;
    _controller?.removeListener(_changed);
    _editable = next;
    _controller = next?.controller;
    _key = found == null ? null : _nearestKey(found!);
    _last = _controller?.text;
    _controller?.addListener(_changed);
  }

  void _changed() {
    final value = _controller?.text;
    if (value == null || value == _last) return;
    _last = value;
    // Protected input is redacted before creating an event or calling a log sink.
    final editable = _editable!;
    final hints = editable.autofillHints?.join(' ') ?? '';
    final protected =
        editable.obscureText || RegExp(r'password|oneTimeCode|creditCard', caseSensitive: false).hasMatch(hints);
    widget.recorder.text(_key, value, protected: protected);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
