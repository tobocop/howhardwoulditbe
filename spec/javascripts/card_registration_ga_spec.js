describe('CardRegistrationGA', function() {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<form class="js-search-form" id="js-authentication-form" action="/stuff">' +
      '</form>' +
      '<div class="js-most-popular-list">' +
      '  <a href="#" class="js-search-most-common-results js-search-results">Linky</a>' +
      '</div>'
    );

    spyOn(CardRegistrationGA, '_pageView').andCallFake(function () {
      return true;
    });
  });

  describe('#bindEvents', function() {
    xit("Find a way to test this that doesn't interfere with card_registration_spec.js");
  });

  describe('#mostPopularListClick', function (e) {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.mostPopularListClick();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/search/clicked_most_popular_list',
        'title': 'User selected institution from "Or choose from these popular banks"'}
      );
    })
  });

  describe('#search', function () {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.search();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/search/saw_search_page',
        'title': 'User saw initial search form'}
      );
    })
  });

  describe('#searchSubmission', function (e) {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.searchSubmission();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/search/submitted_search_form',
        'title': 'User submitted institution search form'}
      );
    })
  });

  describe('#searchResults', function () {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.searchResults();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/search/saw_search_results_page',
        'title': 'User viewed institution search results'}
      );
    })
  });

  describe('#mostCommonSearchResultsClick', function (e) {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.mostCommonSearchResultsClick();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/search/clicked_most_common_search_result',
        'title': 'User clicked on a search result in the "Most Common" section'}
      );
    })
  });

  describe('#searchResultsClick', function (e) {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.searchResultsClick();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/search/clicked_search_result',
        'title': 'User clicked on a search result'}
      );
    })
  });

  describe('#authenticationForm', function () {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.authenticationForm();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/authentication/saw_authentication_form',
        'title': 'User saw institution authentication form'}
      );
    })
  });

  describe('#authenticationFormSubmission', function (e) {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.authenticationFormSubmission();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/authentication/submitted_authentication_form',
        'title': 'User submitted institution authentication form'}
      );
    })
  });

  describe('#firstCommunicatingScreen', function () {
    it('calls to _pageView with the correct values', function() {
      CardRegistrationGA.firstCommunicatingScreen();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/authentication/saw_first_communication_screen',
        'title': 'User saw first "Communicating with your Institution" screen'}
      );
    })
  });

  describe('#authenticationFormError', function () {
    it('calls to _pageView with the correct values', function () {
      CardRegistrationGA.authenticationFormError();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/authentication/authentication_error',
        'title': 'User saw an institution authentication form error'});
    });
  });

  describe('#selectAccount', function () {
    it('calls to _pageView with the correct values', function () {
      CardRegistrationGA.selectAccount();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/authentication/saw_select_account_page',
        'title': 'User saw select account page'});
    });
  });

  describe('#secondCommunicatingScreen', function () {
    it('calls to _pageView with the correct values', function () {
      CardRegistrationGA.secondCommunicatingScreen();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/authentication/saw_second_communication_screen',
        'title': 'User saw "Checking account compatability" modal'});
    });
  });

  describe('#congratulations', function () {
    it('calls to _pageView with the correct values', function () {
      CardRegistrationGA.congratulations();

      expect(CardRegistrationGA._pageView).toHaveBeenCalledWith(
        {'page': '/institutions/congratulations',
        'title': 'User saw congratulations page'});
    });
  });

});
