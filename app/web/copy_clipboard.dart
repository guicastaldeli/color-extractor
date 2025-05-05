import 'package:web/helpers.dart';
import 'package:web/web.dart' as web;
import 'type_detector.dart';

class ClipboardManager {
  static bool init = false;

  static void setupCopy() {
    if(init) return;
    init = true;
  }

  static Future<void> copyToClipboard(String text) async {
    if(!init) setupCopy();

    try {
      web.window.navigator.clipboard.writeText(text);
    } catch(e) {
      print('Failed to Copy $e');
    }
  }

  static void setupCopyButtons(web.Element paletteContent) {
    setupCopy();
    
    final colorEl = paletteContent.querySelectorAll('[data-color-value]');

    for(var i = 0; i < colorEl.length; i++) {
      final el = colorEl.item(i) as web.HTMLElement?;
      if(el == null) continue;

      setupCopyBtnEl(el);
    }
  }

  static void setupCopyBtnEl(web.Element el) {
    //Wrapper
    final wrapper = web.document.createElement('div') as web.HTMLDivElement;
    wrapper.className = 'wrapper';

    //Container
    final container = web.document.createElement('div') as web.HTMLDivElement;
    container.id = '-container-copy-btn';

    //Button
    final copyBtn = web.HTMLButtonElement()
      ..id = '--copy-button'
      ..style.display = 'none'
      ..setAttribute('data-action', 'copy')
    ;

    //Text and Type...
      final colorText = el.textContent ?? '';
      final colorType = TypeDetector.detectType(colorText);
      configCopyBtn(copyBtn, colorType);
      setupBtn(copyBtn, colorText);
    //

    //Append
      el.parentNode?.insertBefore(wrapper, el);
      wrapper.appendChild(el);
      wrapper.appendChild(container);
      container.appendChild(copyBtn);
    //

    //Listeners...
      wrapper.onMouseEnter.listen((_) {
        copyBtn.classList.remove('hide-copy-btn');
        copyBtn.classList.add('show-copy-btn');
      });

      wrapper.onMouseLeave.listen((_) {
        copyBtn.classList.remove('show-copy-btn');
        copyBtn.classList.add('hide-copy-btn');
      });
    //
  }

  static void configCopyBtn(web.HTMLButtonElement button, ColorType type) {
    button.textContent = 'Copy ${TypeDetector.getTypeName(type)}';
    button.setAttribute('data-action', type.toString());
    button.classList.add('color-type-${type.toString().split('.').last}');
  }

  static void setupBtn(web.HTMLButtonElement button, String text) {
    button.onClick.listen((_) async {
      await copyToClipboard(text);

      final originalText = button.textContent;
      button.textContent = 'Copied';
      button.classList.add('copied');

      //Original
        await Future.delayed(Duration(seconds: 2));

        button.textContent = originalText;
        button.classList.remove('copied');
      //
    });
  }
} 