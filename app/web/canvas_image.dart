import 'package:web/helpers.dart';
import 'dart:js_interop';
import 'color_extractor.dart';
import 'session-maganer.dart';
import 'dart:math' as math;
import 'package:web/web.dart' as web;

void setupEventListeners(ColorExtractor extractor) {
  //El
    //Main Container
    final mainContainer = web.document.querySelector('.main') as web.HTMLDivElement;

    //Loaded Image
      //Canvas
        final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
        canvas.id = '__canvas-img';

        final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
        var img = web.document.createElement('img') as web.HTMLImageElement;
      //
      
      final containerCanvas = web.document.getElementById('_content-canvas') as web.HTMLDivElement;
      final paletteContent = web.document.getElementById('_content-palette') as web.HTMLDivElement;
    //

    //Inputs
    final fileInput = web.document.getElementById('--input-file-img') as web.HTMLInputElement?;

    //Url
    final urlForm = web.document.getElementById('-url-form') as web.HTMLFormElement;
    final urlInput = web.document.getElementById('---input-url-img') as web.HTMLInputElement;
  //

  //Session
    //Sessions
    final uploadSession = web.document.getElementById('-for-img') as web.HTMLElement;
    final loadedSession = web.document.getElementById('-for-loaded-img') as web.HTMLElement;

    final sessionManager = SessionManager(
      {
        AppSession.main: uploadSession,
        AppSession.loaded: loadedSession
      },
      initialSession: AppSession.main
    );
  //

  //Display Colors
  void displayColors(List<Map<String, dynamic>> colors, web.Element paletteContent) {
    paletteContent.innerHTML = '';

    for(final color in colors) {
      final colorItemContainer = web.document.createElement('div') as web.HTMLDivElement;
      colorItemContainer.id = '_content-color-display';

      final colorDiv = web.document.createElement('div') as web.HTMLDivElement;
      colorDiv.id = '__color-div';
      colorDiv.style.backgroundColor = 'rgb(${color['r']}, ${color['g']}, ${color['b']})';

      final colorInfoContainer = web.document.createElement('div') as web.HTMLDivElement;
      colorInfoContainer.id = '__content-color-type';

      final rgbString = color['rgbToString'] as String;
      final hex = color['hex'] as String;
      
      //Display RGB and Hex
        //RGB
          final colorRgbText = web.document.createElement('p') as HTMLParagraphElement;
          colorRgbText.id = '___color-rgb-text';
          colorRgbText.textContent = rgbString;

       //

        //Hex
          final colorHexText = web.document.createElement('p') as HTMLParagraphElement;
          colorHexText.id = '___color-hex-text';
          colorHexText.textContent = hex;
        //

        //Append
        colorInfoContainer.appendChild(colorRgbText);
        colorInfoContainer.appendChild(colorHexText);
      //

      //Append
      colorItemContainer.appendChild(colorDiv);
      colorItemContainer.appendChild(colorInfoContainer);
      paletteContent.appendChild(colorItemContainer);
    }
  }

  //Process Image
    void processImage(web.HTMLImageElement img) {
      //...
        containerCanvas.querySelector('#---canvas-img')?.remove();
      //

      //Max Dimensions
        const maxWidth = 600;
        const maxHeight = 800;
        double scaleFactor = 1.0;

        if(img.width > maxWidth || img.height > maxHeight) {
          scaleFactor = math.min(maxWidth / img.width, maxHeight / img.height);
          final finalWidth = img.width * scaleFactor;
          final finalHeight = img.height * scaleFactor;

          canvas.width = finalWidth.toInt();
          canvas.height = finalHeight.toInt();

          containerCanvas.style.width = '${finalWidth}px';
          containerCanvas.style.height = '${finalHeight}px';
          
          ctx.clearRect(0, 0, canvas.width, canvas.height);
        }
      //

      ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
      containerCanvas.appendChild(canvas);

      //Data
      final data = ctx.getImageData(0, 0, canvas.width, canvas.height);
      final colors = extractor.extractColors(data);
      displayColors(colors, paletteContent);
    }

    //Load Screen
    bool loaderActive = false;

    //Loader
      void showLoader() {
        if(loaderActive) return;
        loaderActive = true;

        //Load Screen
        final loadScreen = web.document.createElement('div') as web.HTMLDivElement;
        loadScreen.className = 'load-screen';
        mainContainer.appendChild(loadScreen);

        //Load Text
        final loadTxt = web.document.createElement('p') as web.HTMLParagraphElement;
        String loadContent = 'Loading Image';
        loadTxt.id = 'load-txt';
        loadTxt.textContent = loadContent;
        loadScreen.appendChild(loadTxt);

        //Container
        sessionManager.changeSession(AppSession.main);

        //Animation
          int ellipsisCount = 0;
          const maxDots = 3;

          final timer = web.window.setInterval((JSAny _) {
            ellipsisCount = (ellipsisCount + 1) % (maxDots + 1);
            final dots = '.' * ellipsisCount;
            loadTxt.textContent = '$loadContent$dots';
            return null;
          }.toJS, 500.toJS);
        //

        loadScreen.setAttribute('data-timer-id', timer.toString());
      }
    //

    //Display Container
      void displayContainer() {
        if(loaderActive) {
          final exLoadScreen = mainContainer.querySelector('.load-screen');
          
          if(exLoadScreen != null) {
            final timerId = exLoadScreen.getAttribute('data-timer-id');
            if(timerId != null) web.window.clearInterval(int.parse(timerId));
            exLoadScreen.remove();
          }

          loaderActive = false;
        }

        sessionManager.changeSession(AppSession.loaded);

        //Back
          void backBtn() {
            final backContent = web.document.getElementById('_content-back') as HTMLDivElement;
            backContent.querySelector('#---back-btn')?.remove();

            final backBtn = web.document.createElement('button') as HTMLButtonElement;
            backBtn.id = '---back-btn';
            backBtn.textContent = 'Back';

            //Click
            backBtn.onClick.listen((_) {
              ctx.clearRect(0, 0, canvas.width, canvas.height);
              containerCanvas.querySelector('#---canvas-img')?.remove();

              img.removeAttribute('src');
              img = web.document.createElement('img') as web.HTMLImageElement;

              sessionManager.changeSession(AppSession.main);

              if(fileInput != null) fileInput.value = '';
              urlInput.value = '';
              loaderActive = false;
            });

            backContent.appendChild(backBtn);
          }

          backBtn();
        //
      }
    //

    //Display Image
    void displayImage(web.HTMLImageElement img, {String? url}) {
      final loadListener = (web.Event _) {
        if(img.width > 0 && img.height > 0) {
          processImage(img);
          displayContainer();
        }
      }.toJS;

      final errorListener = (web.Event _) {
        print('Error loading image');
      }.toJS;

      img.removeEventListener('load', loadListener);
      img.removeEventListener('error', errorListener);

      img.addEventListener('load', loadListener);
      img.addEventListener('error', errorListener);

      if(url != null) {
        final cacheBuster = DateTime.now().millisecondsSinceEpoch;
        img.src = '$url?cache=$cacheBuster';
      }
    }
  //

  //Input    
    fileInput?.onChange.listen((e) {
      final file = fileInput.files?.item(0);
      if(file == null) return;

      showLoader();

      //Load
        final reader = web.FileReader();

        reader.onLoadEnd.listen((e) {
          img.src = (reader.result as JSAny).toString();
          displayImage(img);
        });

        reader.readAsDataURL(file);
      //
    });
  //

  //Url
  urlForm.onSubmit.listen((e) {
    e.preventDefault();

    showLoader();

    final url = urlInput.value.trim();
    if(url.isEmpty) return;

    //Img
      img.crossOrigin = 'Anonymous';
      displayImage(img);
      img.src = url;
    //
  });
}