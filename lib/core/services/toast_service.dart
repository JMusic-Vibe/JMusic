import 'dart:async';

class ToastEvent {
  final String key;
  final Map<String, String>? args;

  ToastEvent(this.key, {this.args});
}

/// Simple global toast service used by non-UI code to request a UI toast.
class ToastService {
  final _ctrl = StreamController<ToastEvent>.broadcast();

  Stream<ToastEvent> get stream => _ctrl.stream;

  void show(String key, {Map<String, String>? args}) {
    _ctrl.add(ToastEvent(key, args: args));
  }

  void dispose() {
    _ctrl.close();
  }
}

final toastService = ToastService();
