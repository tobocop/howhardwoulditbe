describe('Plink.CFCallbacks', function () {
  describe("cardLinkProcessComplete", function () {
    it("triggers the cardLinkProcessComplete event", function () {
      var eventSpy = spyOnEvent(document, 'cardLinkProcessComplete');

      Plink.CFCallbacks.cardLinkProcessComplete();

      expect('cardLinkProcessComplete').toHaveBeenTriggeredOn(document);
      expect(eventSpy).toHaveBeenTriggered();
    });
  });
});

