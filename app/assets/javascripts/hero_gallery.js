(function ($) {
  Plink.HeroGallery = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.init = function () {
      base.bindEvents();

      $('.hero-gallery-inner').bjqs({
        width       : 1800,
        height      : 380,
        responsive  : true
      });
    };

    base.bindEvents = function () {
      $(document).on('click', '.hero-promotion-link', base._recordClick);
    };

    base._recordClick = function(e) {
      var hero_promotion_data = $(this).data();

      $.ajax({
        url: hero_promotion_data.url
      });
    };

    base.init();
  };

  Plink.HeroGallery.defaultOptions = {};

  $.fn.heroGallery = function (options) {
    return this.each(function () {
      (new Plink.HeroGallery(this, options));
    });
  };

})(jQuery);
