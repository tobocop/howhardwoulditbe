describe('Plink.GigyaShareFlowWidget', function () {

  beforeEach(function () {
    window.gigya = {socialize: {showShareUI: function() {}}};
    $('#jasmine_content').html('');
  });

  describe('#setup', function () {
    it('initializes the click handler on the right element', function () {
      $('#jasmine_content').html('<div data-facebook-share-flow-share-widget="true"></div>');

      spyOn(Plink.GigyaAction, 'create').andReturn('widget');
      spyOn(gigya.socialize, 'showShareUI');

      Plink.GigyaShareFlowWidget.setup();

      $('[data-facebook-share-flow-share-widget]').trigger('click');

      expect(window.gigya.socialize.showShareUI).toHaveBeenCalledWith({
        userAction: 'widget',
        enabledProviders: 'facebook,twitter',
        onSendDone: Plink.GigyaShareFlowWidget._onSendDone
      });
    });
  });
});

