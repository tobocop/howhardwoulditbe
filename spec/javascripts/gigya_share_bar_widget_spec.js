describe('Plink.GigyaShareBarWidget', function () {

  beforeEach(function () {
    window.gigya = {socialize: {showShareBarUI: function() {}}};
    $('#jasmine_content').html('');
  });

  describe('#setup', function () {
    it('shows the Share Bar UI when share-bar-widget is on the page', function () {
      spyOn(gigya.socialize, 'showShareBarUI');

      spyOn(Plink.GigyaAction, 'create').andReturn('action');

      $('#jasmine_content').html('<div id="share-bar-widget"></div>');

      Plink.GigyaShareBarWidget.setup();

      expect(window.gigya.socialize.showShareBarUI).toHaveBeenCalledWith({
        userAction: 'action',
        shareButtons: 'facebook-like,twitter-tweet',
        containerID: 'share-bar-widget',
        cid: ''
      });
    });

    it('does not show the Add Connections UI when social-link-widget is not on the page', function () {
      spyOn(gigya.socialize, 'showShareBarUI');

      Plink.GigyaAddConnectionsWidget.setup();
      expect(window.gigya.socialize.showShareBarUI).not.toHaveBeenCalled();
    });
  });
});

