import 'package:web/web.dart' as web;
import 'dart:js_interop';

class Validator {
  static bool? validateEmptyUrl(String? url) {
    if(url == null || url.trim().isEmpty) return false;
    return true;
  }

  static bool? validateUrlFormat(String? url) {
    if(url == null || url.trim().isEmpty) return true;

    try {
      final uri = Uri.parse(url);
      if(!uri.hasAbsolutePath) return false;
    } catch(e) {
      return false;
    }

    return true;
  }

  static bool? validateImageUrl(String? url) {
    if(url == null || url.trim().isEmpty) return true;
    return true;
  }

  static bool validateImageUrlInput(String? url) {
    final emptyValid = validateEmptyUrl(url);
    if(emptyValid == false) return false;

    final formatValid = validateUrlFormat(url);
    if(formatValid == false) return false;

    final imageValid = validateImageUrl(url);
    if(imageValid == false) return false;

    return true;
  }
}

class ErrorHandler {
  static void showError(web.HTMLElement? el) {
    if(el == null) return;
    el.classList.add('error');
  }

  static void hideError(web.HTMLElement? el) {
    if(el != null) el.classList.remove('error');
    el?.classList.remove('error');
    
    final listener = ((web.Event event) {
      el?.classList.remove('error');
    }).toJS as web.EventListener;

    el?.addEventListener('input', listener);
  }
}