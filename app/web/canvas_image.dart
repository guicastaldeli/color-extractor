import 'package:web/helpers.dart';
import 'dart:js_interop';
import 'color_extractor.dart';
import 'package:web/web.dart' as web;

void setupEventListeners(ColorExtractor extractor) {
  //El
    //Main Container
    final mainContainer = web.document.querySelector('.main') as web.HTMLDivElement;

    //Img Container
    final imgContainer = web.document.getElementById('-container-img') as web.HTMLDivElement;

    //Loaded Image
      //Canvas
        final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
        canvas.id = '---canvas-img';

        final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
        var img = web.document.createElement('img') as web.HTMLImageElement;
      //
      
      final loadedContainer = web.document.getElementById('-container-loaded-img') as web.HTMLDivElement;
      final containerCanvas = web.document.getElementById('---container-canvas') as web.HTMLDivElement;
      final paletteContainer = web.document.getElementById('---container-palette') as web.HTMLDivElement;
      final paletteContent = web.document.getElementById('_content-palette') as web.HTMLDivElement;
    //

    //Inputs
    final fileInput = web.document.getElementById('--input-file-img') as web.HTMLInputElement?;

    //Url
    final urlForm = web.document.getElementById('-url-form') as web.HTMLFormElement;
    final urlInput = web.document.getElementById('---input-url-img') as web.HTMLInputElement;
  //

  //Display Colors
  void displayColors(List<Map<String, dynamic>> colors, web.Element paletteContent) {
    paletteContent.innerHTML = '';

    for(final color in colors) {
      final colorDiv = web.document.createElement('div') as web.HTMLDivElement;
      colorDiv.id = '_color-div';
      colorDiv.style
        ..width = '50px'
        ..height = '50px'
        ..backgroundColor = 'rgb(${color['r']}, ${color['g']}, ${color['b']})'
        ..display = 'inline-block'
        ..margin = '5px'
      ;

      final hex = color['hex'] as String;
      final rgbString = color['rgbToString'] as String;
      
      //Display RGB and Hex
      colorDiv.text = '$hex\n$rgbString';

      //Append
      paletteContent.append(colorDiv);
    }
  }

  //Process Image
    void processImage(web.HTMLImageElement img) {
      //...
        containerCanvas.querySelector('#---canvas-img')?.remove();
      //

      canvas.width = img.width;
      canvas.height = img.height;
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      ctx.drawImage(img, 0, 0);
      containerCanvas.append(canvas);

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
        imgContainer.style.display = 'none';

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

        imgContainer.style.display = 'none';
        loadedContainer.style.display = 'flex';

        //Back
          void backBtn() {
            final containerBack = web.document.getElementById('---container-back') as HTMLDivElement;
            containerBack.querySelector('#---back-btn')?.remove();

            final backBtn = web.document.createElement('button') as HTMLButtonElement;
            backBtn.id = '---back-btn';
            backBtn.textContent = 'Back';

            //Click
            backBtn.onClick.listen((_) {
              ctx.clearRect(0, 0, canvas.width, canvas.height);
              containerCanvas.querySelector('#---canvas-img')?.remove();

              img.removeAttribute('src');
              img = web.document.createElement('img') as web.HTMLImageElement;

              loadedContainer.style.display = 'none';
              imgContainer.style.display = 'flex';

              if(fileInput != null) fileInput.value = '';
              urlInput.value = '';
              loaderActive = false;
            });

            containerBack.appendChild(backBtn);
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