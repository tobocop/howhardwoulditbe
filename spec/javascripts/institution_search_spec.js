describe('InstitutionSearch', function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      ' <div id="institution-search">' +
      '   <input id="institution_name" type="text"></input>' +
      ' </div>'
    );
  });

  describe('#setFocusOnSearchBox', function () {
    it('displays the cursor in the search input field', function (){
      InstitutionSearch.setFocusOnSearchBox();

      expect($(document.activeElement)).toEqual($('#institution_name'));
    });
  });

  describe('#clearSearchBox', function() {
    it('clears the search input field when the Clear button is clicked', function(){
      $('#institution_name').val('This is a search');
      expect($('#institution_name').val()).toNotEqual('');

      InstitutionSearch.clearSearchBox();

      expect($('#institution_name').val()).toEqual('');
    });
  })
});
