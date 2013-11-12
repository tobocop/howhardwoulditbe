describe('Plink.heroGallery', function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<div class="hero-gallery-inner">' +
        '<span class="bjqs">' +
        '</span' +
      '</div>'
    );
  });

  describe('#setUp', function () {
    it('calls to Basic jquery Slider', function () {
      spyOn($.fn, 'bjqs');

      $('.hero-gallery-inner').heroGallery();

      var hero_gallery_params = {
        width       : 1800,
        height      : 380,
        responsive  : true
      };

      expect($('.hero-gallery-inner').bjqs).toHaveBeenCalledWith(hero_gallery_params);
    });
  });
});
