describe('MySpec', function() {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<div>temp</div>'
    );
  });

  describe('#things', function() {
    it('Does things', function() {
      expect('this').toEqual('this');
    });
  });
});
