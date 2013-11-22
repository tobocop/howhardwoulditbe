(function ($) {
  Plink.HeroGallery = function (el, options) {
    var $wrapper = $(el),
        $slider = $wrapper.find('ul.gallery'),
        $slides = $slider.children('li.slide'),
        $markers = null;

    var state = {
      slideCount: $slides.length,
      animating: false,
      currentIndex: 0,
      timer: null
    };

    var responsive = {
      width: null,
      height: null,
      ratio: null
    };

    init = function() {
      _setHeight();
      _setupCaptions();
      _setupMarkers();
      _startTimer();
      bindEvents();

      $(window).resize(_setHeight);
      $(document).on('click', '.marker', _markerClick);
    };

    bindEvents = function () {
      $(document).on('click', '.hero-promotion-link', _recordClick);
    };

    _recordClick = function(e) {
      var hero_promotion_data = $(this).data();

      $.ajax({
        url: hero_promotion_data.url
      });
    };


    _startTimer = function() {
      timer = setTimeout(_gotoNextSlide, 4000);
    };

    _stopTimer = function() {
      clearTimeout(timer);
    };

    _gotoNextSlide = function(slideNumber) {
      _gotoSlide(state.currentIndex + 1);
    };

    _markerClick = function(event) {
      slideNumber = $(this).data('slidenumber');
      _gotoSlide(slideNumber);
    };

    _gotoSlide = function(slideNumber) {
      if(!state.animating){
        _gotoSlideStart();

        $slides.eq(state.currentIndex).fadeOut(450);

        $('.marker').removeClass('active-marker');
        $('.marker').eq(slideNumber).addClass('active-marker');

        $slides.eq(slideNumber).fadeIn(450, _gotoSlideComplete(slideNumber));
      };
    };

    _gotoSlideStart = function(){
      state.animating = true;
      _stopTimer();
    };

    _gotoSlideComplete = function(slideNumber){
      state.currentIndex = slideNumber;
      if(state.slideCount == slideNumber + 1){
        state.currentIndex = -1;
      };
      state.animating = false;
      _startTimer();
    };

    _setHeight = function(width, height) {
      responsive.width = $wrapper.outerWidth();
      responsive.ratio = responsive.width/1800;
      responsive.height = 380 * responsive.ratio;

      $wrapper.css({
        'height': responsive.height
      });

      $slides.find('img').css({
        'height': responsive.height
      });
    };

    _setupCaptions = function() {
      $.each($slides, function (key, slide) {
        var slideImage = $(slide).find('img');
        captionText = slideImage.attr('title')
        if(captionText) {
          caption = $('<p class="caption">' + slideImage.attr('title') + '</p>');
          caption.appendTo($(slideImage).parent());
        }
      });
    };

    _setupMarkers = function() {
      $markers = $('<ol class="markers"></ol>');

      $.each($slides, function(slideNumber, slide){
        var marker = $('<li class="marker" data-slidenumber="' + slideNumber + '">&nbsp;</li>');
        marker.appendTo($markers);
      });

      $markers.appendTo($wrapper);

      var offset = (responsive.width - $markers.width()) / 2;
      $markers.css('left', offset);
      $markers.find('li:first-child').addClass('active-marker');
    };

    init();
  };

  $.fn.heroGallery = function (options) {
    return this.each(function () {
      (new Plink.HeroGallery(this, options));
    });
  };
})(jQuery);
