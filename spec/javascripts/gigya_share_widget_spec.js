describe('Plink.GigyaShareWidget', function () {

  beforeEach(function () {
    window.gigya = {socialize: {showShareUI: function() {}}};
    $('#jasmine_content').html('');
  });

  describe('#setup', function () {
    it('initializes the click handler on the right element', function () {
      $('#jasmine_content').html('<div class="invite-friend-widget"></div>');

      spyOn(Plink.GigyaAction, 'create').andReturn('widget');
      spyOn(gigya.socialize, 'showShareUI');

      Plink.GigyaShareWidget.setup();

      $('.invite-friend-widget').trigger('click');

      expect(window.gigya.socialize.showShareUI).toHaveBeenCalledWith({userAction: 'widget', enabledProviders: 'facebook,twitter'});
    });
  });
});

