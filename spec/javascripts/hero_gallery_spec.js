describe('Plink.HeroGallery', function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<div class="hero-gallery-inner">' +
        '<ul class="gallery">' +
          '<li id="slideOne" class="slide"><img title="first image" /></li>' +
          '<li id="slideTwo" class="slide"><a href="#" class="hero-promotion-link" data-url="www.stuff.com"><img title="second image" /></a></li>' +
        '</ul>' +
      '</div>'
    );

    spyOn(window, 'setTimeout');
    spyOn(window, 'clearTimeout');
    $.fx.off = true;
  });

  describe('#init', function () {
    it('sets the caption paragraph based off of the title attributes on the images', function(){
      $('.hero-gallery-inner').heroGallery();
      expect($('#slideOne p').html()).toEqual('first image');
      expect($('#slideTwo p').html()).toEqual('second image');
    })

    it('creates controls for the hero gallery', function(){
      $('.hero-gallery-inner').heroGallery();
      expect($('.hero-gallery-inner .markers').length).toEqual(1);
      expect($('.hero-gallery-inner .markers .marker').length).toEqual(2);
    })
  })

  describe('Controls', function() {
    it('changes the active marker when the marker is clicked', function () {
      expect($('#slideOne').css('display')).toEqual('list-item');

      $('.hero-gallery-inner').heroGallery();
      $('.marker')[1].click();

      expect($('#slideOne').css('display')).toEqual('none');
      expect($('#slideTwo').css('display')).toEqual('list-item');

      $('.marker')[0].click();

      expect($('#slideOne').css('display')).toEqual('list-item');
      expect($('#slideTwo').css('display')).toEqual('none');
    })

    it('binds a click event to the .hero-promotion-link', function() {
      $('.hero-gallery-inner').heroGallery();

      spyOn($, "ajax");

      $('.hero-promotion-link').click();

      expect($.ajax).toHaveBeenCalledWith({url: 'www.stuff.com'});
    });
  });

  describe('Caption', function() {
    it('puts the caption inside whatever element the image is inside', function () {
      $('.hero-gallery-inner').heroGallery();
      expect($('#slideOne p').length).toEqual(1);
      expect($('#slideTwo a p').length).toEqual(1);
    })
  })
});
