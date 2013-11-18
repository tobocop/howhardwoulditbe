describe('Plink.heroGallery', function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<div class="hero-gallery-inner">' +
      '  <span class="bjqs">' +
      '    <a href="#" class="hero-promotion-link" data-url="www.stuff.com">Click Me</a>' +
      '  </span' +
      '</div>'
    );
  });

  describe('Hero Gallery', function () {
    it('calls to Basic jquery Slider on initialization', function () {
      spyOn($.fn, 'bjqs');

      $('.hero-gallery-inner').heroGallery();

      var hero_gallery_params = {
        width       : 1800,
        height      : 380,
        responsive  : true
      };

      expect($('.hero-gallery-inner').bjqs).toHaveBeenCalledWith(hero_gallery_params);
    });

    it('binds a click event to the .hero-promotion-link', function() {
      $('.hero-gallery-inner').heroGallery();

      spyOn($, "ajax");

      $('.hero-promotion-link').click();

      expect($.ajax).toHaveBeenCalledWith({url: 'www.stuff.com'});
    });
  });
});
