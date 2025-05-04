import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:web/helpers.dart';

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

    final el = paletteContent.querySelectorAll('#___color-rgb-text, #___color-hex-text');
    
    for(var i = 0; i < el.length; i++) {
      final e = el.item(i);
      if(e == null) continue;

      final textEl = e as web.HTMLElement;

      final wrapper = web.document.createElement('div') as web.HTMLDivElement;
      wrapper.className = 'wrapper';

      final container = web.document.createElement('div') as web.HTMLDivElement;
      container.id = '-container-copy-btn';

      final copyBtn = web.document.createElement('button') as web.HTMLButtonElement;
      copyBtn.id = '--copy-button';
      copyBtn.textContent = 'Copy';
      copyBtn.classList.add('hide-copy-btn');

      //Append
      textEl.parentNode?.insertBefore(wrapper, textEl);
      wrapper.appendChild(textEl);
      wrapper.appendChild(container);
      container.appendChild(copyBtn);

      //Container Functions...
        wrapper.onMouseEnter.listen((_) {
          copyBtn.classList.remove('hide-copy-btn');
          copyBtn.classList.add('show-copy-btn');
        });

        wrapper.onMouseLeave.listen((_) {
          copyBtn.classList.remove('show-copy-btn');
          copyBtn.classList.add('hide-copy-btn');
        });

        copyBtn.onClick.listen((_) async {
          await copyToClipboard(textEl.textContent ?? '');
        });
      //
    }
  }
}