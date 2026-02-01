import 'package:flutter/foundation.dart';

/// Basis-ViewModel Klasse mit ChangeNotifier für reaktive Updates
abstract class BaseViewModel extends ChangeNotifier {
  bool _disposed = false;
  bool _busy = false;
  String? _errorMessage;

  bool get busy => _busy;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Setzt den Busy-Status und benachrichtigt Listener
  @protected
  void setBusy(bool value) {
    if (_disposed) return;
    _busy = value;
    notifyListeners();
  }

  /// Setzt eine Fehlermeldung
  @protected
  void setError(String? message) {
    if (_disposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  /// Löscht die Fehlermeldung
  void clearError() {
    if (_disposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Führt eine async Aktion aus mit automatischem Busy-Handling
  @protected
  Future<T?> runBusyAction<T>(Future<T> Function() action) async {
    if (_busy || _disposed) return null;

    setBusy(true);
    clearError();

    try {
      return await action();
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setBusy(false);
    }
  }

  /// Sichere Benachrichtigung (prüft ob disposed)
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
