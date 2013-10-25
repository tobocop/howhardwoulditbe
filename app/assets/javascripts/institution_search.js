(function () {
  InstitutionSearch = {
    setFocusOnSearchBox: function () {
      $('#institution_name').focus();
    },

    clearSearchBox: function () {
      $('#institution_name').val('');
      return false;
    }
  }
})(window);

$(function () {
  if ($('#institutions-search').length) {
    InstitutionSearch.setFocusOnSearchBox();
  };

  if ($('#institutions-search_results').length) {
    $(document).on('click', '#js-clear-search-box', InstitutionSearch.clearSearchBox);
  };
});
