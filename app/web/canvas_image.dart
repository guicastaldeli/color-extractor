import 'package:web/helpers.dart';
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:web/web.dart' as web;
import 'color_extractor.dart';
import 'validator.dart';
import 'session_manager.dart';
import 'copy_clipboard.dart';
import 'loader.dart';

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

  //Copy
  ClipboardManager.setupCopy();

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
          final colorRgbText = web.document.createElement('p')
            ..id = '___color-rgb-text'
            ..textContent = rgbString
            ..setAttribute('data-color-value', rgbString)
          ;
       //

        //Hex
          final colorHexText = web.document.createElement('p')
            ..id = '___color-hex-text'
            ..textContent = hex
            ..setAttribute('data-color-value', hex)
          ;
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

    ClipboardManager.setupCopyButtons(paletteContent);
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
    final loader = Loader(mainContainer);

    //Loader
      void showLoader() {
        loader.show();
        sessionManager.changeSession(AppSession.main);
      }
    //

    //Display
      //Container
      void displayContainer() {
        //Loader
        loader.hide();
        sessionManager.changeSession(AppSession.loaded);

        //Back
          void backBtn() {
            final backContent = web.document.getElementById('_content-back') as HTMLDivElement;
            backContent.querySelector('#---back-btn')?.remove();

            final backBtn = web.document.createElement('button') as HTMLButtonElement;
            backBtn.id = '---back-btn';
            backBtn.textContent = 'Back';

            //Click
            void resetState() {
              ctx.clearRect(0, 0, canvas.width, canvas.height);
              containerCanvas.querySelector('#---canvas-img')?.remove();

              img = web.document.createElement('img') as web.HTMLImageElement;
              sessionManager.changeSession(AppSession.main);

              if(fileInput != null) fileInput.value = '';
              urlInput.value = '';
              loader.hide();
            }

            backBtn.onClick.listen((_) => resetState());
            backContent.appendChild(backBtn);
          }

          backBtn();
        //
      }

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

    final url = urlInput.value.trim();
    
    //Empty
      ErrorHandler.hideError(urlInput);

      var validateError = Validator.validateImageUrlInput(url);
      if(!validateError) {
        ErrorHandler.showError(urlInput);
        return;
      }
    //

    showLoader();

    //Img
      img.crossOrigin = 'Anonymous';
      displayImage(img);
      img.src = url;
    //
  });
}