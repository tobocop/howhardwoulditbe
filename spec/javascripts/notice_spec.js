describe('Plink.Notice', function () {

  beforeEach(function () {
    $('#jasmine_content').html('<div class="flash-container"></div>');
  });

  describe("display", function() {
    it("shows the flash message with the text given to it", function () {
      Plink.Notice.display('Check me out!');

      expect($('#jasmine_content').find('.flash-container').html()).toEqual('<div class="flash-msg">Check me out!</div>');
    });
  })
});