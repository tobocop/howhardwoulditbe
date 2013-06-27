describe('Plink.GigyaAddConnectionsWidget', function () {

  beforeEach(function () {
    window.gigya = {socialize: {showAddConnectionsUI: function() {}}};
    $('#jasmine_content').html('');
  });

  describe('#setup', function () {
    it('shows the Add Connections UI when social-link-widget is on the page', function () {
      spyOn(gigya.socialize, 'showAddConnectionsUI');

      $('#jasmine_content').html('<div id="social-link-widget"></div>');

      Plink.GigyaAddConnectionsWidget.setup();
      expect(window.gigya.socialize.showAddConnectionsUI).toHaveBeenCalledWith({showTermsLink: false, showEditLink: true, hideGigyaLink: true, enabledProviders: 'facebook,twitter', containerID: 'social-link-widget', width: 65, height: 70});
    });

    it('does not show the Add Connections UI when social-link-widget is not on the page', function () {
      spyOn(gigya.socialize, 'showAddConnectionsUI');

      Plink.GigyaAddConnectionsWidget.setup();
      expect(window.gigya.socialize.showAddConnectionsUI).not.toHaveBeenCalled();
    });
  });
});

