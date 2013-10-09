describe('Plink.ContestPageCfCallbacks', function () {

  beforeEach(function () {
    spy = spyOn(Plink.ContestPageCfCallbacks, '_cardLinkProcessComplete');
  });

  describe('#setup', function () {
    it('initializes a handler for cardLinkProcessComplete', function() {
      Plink.ContestPageCfCallbacks.setup();
      $(document).trigger('cardLinkProcessComplete');
      expect(spy).toHaveBeenCalled();
    });
  });

  describe('#__cardLinkProcessComplete', function () {
    // this is pending because the refresh messes up jasmine
    xit('refreshes the page with card_linked=true');
  });

});
