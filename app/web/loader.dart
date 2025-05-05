import 'package:web/web.dart' as web;
import 'dart:js_interop';

class Loader {
  final web.HTMLElement mainContainer;
  bool _active = false;
  int? _timerId;

  Loader(this.mainContainer);

  void show() {
    if(_active) return;
    _active = true;

    //Load Screen
    final loadScreen = web.document.createElement('div') as web.HTMLDivElement;
    loadScreen.className = 'load-screen';
    mainContainer.appendChild(loadScreen);

    //Load Text
    final loadTxt = web.document.createElement('p') as web.HTMLParagraphElement;
    String loadContent = 'Extraindo Cores';
    loadTxt.id = 'load-txt';
    loadTxt.textContent = loadContent;
    loadScreen.appendChild(loadTxt);

    //Animation
      int ellipsisCount = 0;
      const maxDots = 3;

      final timer = (() {
        ellipsisCount = (ellipsisCount + 1) % (maxDots + 1);
        final dots = '.' * ellipsisCount;
        loadTxt.textContent = '$loadContent$dots';
      }).toJS;

      _timerId = web.window.setInterval(timer, 30000.toJS);
    //
  }

  void hide() {
    if(!_active) return;

    final exLoadScreen = mainContainer.querySelector('.load-screen');
          
    if(exLoadScreen != null) {
      if(_timerId != null) web.window.clearInterval(_timerId!);
      exLoadScreen.remove();
    }

    _active = false;
    _timerId = null;
  }

  bool get isActive => _active;
}