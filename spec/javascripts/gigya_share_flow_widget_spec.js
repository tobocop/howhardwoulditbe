describe('Plink.GigyaShareFlowWidget', function () {
  beforeEach(function () {
    window.gigya = {socialize: {showShareUI: function() {}}};
    $('#jasmine_content').html('<div data-facebook-share-flow-share-widget="true"></div>');
  });

  describe('#setup', function () {
    it('initializes the click handler on the right element', function () {
      spyOn(Plink.GigyaAction, 'create').andReturn('widget');
      spyOn(gigya.socialize, 'showShareUI');

      Plink.GigyaShareFlowWidget.setup();

      $('[data-facebook-share-flow-share-widget]').trigger('click');

      expect(window.gigya.socialize.showShareUI).toHaveBeenCalled();
    });
  });

  describe('#_clickHandler', function () {
    beforeEach(function() {
      mock_click_event = {type: 'click', preventDefault: function () {}};
    });

    it('calls the gigya share modal', function () {
      spyOn(Plink.GigyaAction, 'create').andReturn('widget');
      spyOn(gigya.socialize, 'showShareUI');

      Plink.GigyaShareFlowWidget._clickHandler(mock_click_event);

      expect(window.gigya.socialize.showShareUI).toHaveBeenCalledWith({
        userAction: 'widget',
        enabledProviders: 'facebook,twitter',
        onSendDone: jasmine.any(Function)
      });
    });
  });

  describe('#_onSendDone', function () {
    it('makes an AJAX request', function(){
      spyOn($, 'ajax').andCallFake(function () { return $.Deferred(); });

      Plink.GigyaShareFlowWidget._onSendDone('status_url');

      expect($.ajax).toHaveBeenCalledWith({url: 'status_url', data: {shared: true}});
    });

    it('redirects to the wallet page', function () {
      spyOn($, 'ajax').andCallFake(function () { return $.Deferred().resolve(); });
      spy = spyOn(Plink.GigyaShareFlowWidget, 'redirectToWalletWithLinkCardModal');

      Plink.GigyaShareFlowWidget._onSendDone('status_url');

      expect(spy).toHaveBeenCalled;
    });
  });
});

