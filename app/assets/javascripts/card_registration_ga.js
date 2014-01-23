(function () {
  CardRegistrationGA = {
    bindEvents: function () {
      $(document).on('click', '.js-most-popular-list a', CardRegistrationGA.mostPopularListClick);
      $(document).on('submit', '.js-search-form', CardRegistrationGA.searchSubmission);
      $(document).on('click', '.js-search-most-common-results', CardRegistrationGA.mostCommonSearchResultsClick);
      $(document).on('click', '.js-search-results', CardRegistrationGA.searchResultsClick);
      $(document).on('submit', '#js-authentication-form', CardRegistrationGA.authenticationFormSubmission);
    },

    _pageView: function(ga_object) {
      if (typeof(ga) !== 'undefined') {
        ga('send', 'pageview', ga_object);
      }
    },

    mostPopularListClick: function (e) {
      CardRegistrationGA._pageView({'page': '/institutions/search/clicked_most_popular_list',
        'title': 'User selected institution from "Or choose from these popular banks"'});
    },

    search: function () {
      CardRegistrationGA._pageView({'page': '/institutions/search/saw_search_page',
        'title': 'User saw initial search form'});
    },

    searchSubmission: function (e) {
      CardRegistrationGA._pageView({'page': '/institutions/search/submitted_search_form',
        'title': 'User submitted institution search form'});
    },

    searchResults: function () {
      CardRegistrationGA._pageView({'page': '/institutions/search/saw_search_results_page',
        'title': 'User viewed institution search results'});
    },

    mostCommonSearchResultsClick: function (e) {
      CardRegistrationGA._pageView({'page': '/institutions/search/clicked_most_common_search_result',
        'title': 'User clicked on a search result in the "Most Common" section'});
    },

    searchResultsClick: function (e) {
      CardRegistrationGA._pageView({'page': '/institutions/search/clicked_search_result',
        'title': 'User clicked on a search result'});
    },

    authenticationForm: function () {
      CardRegistrationGA._pageView({'page': '/institutions/authentication/saw_authentication_form',
        'title': 'User saw institution authentication form'});
    },

    authenticationFormSubmission: function (e) {
      CardRegistrationGA._pageView({'page': '/institutions/authentication/submitted_authentication_form',
        'title': 'User submitted institution authentication form'});
    },

    firstCommunicatingScreen: function () {
      CardRegistrationGA._pageView({'page': '/institutions/authentication/saw_first_communication_screen',
        'title': 'User saw first "Communicating with your Institution" screen'});
    },

    authenticationFormError: function () {
      CardRegistrationGA._pageView({'page': '/institutions/authentication/authentication_error',
        'title': 'User saw an institution authentication form error'});
    },

    selectAccount: function () {
      CardRegistrationGA._pageView({'page': '/institutions/authentication/saw_select_account_page',
        'title': 'User saw select account page'});
    },

    secondCommunicatingScreen: function () {
      CardRegistrationGA._pageView({'page': '/institutions/authentication/saw_second_communication_screen',
        'title': 'User saw "Checking account compatability" modal'});
    },

    congratulations: function () {
      CardRegistrationGA._pageView({'page': '/institutions/congratulations',
        'title': 'User saw congratulations page'});
    }
  }
})(window);

$(function () {
  var card_registration = "#institutions-search, #institutions-search_results, #institutions-authentication";

  if ($(card_registration).length) {
    CardRegistrationGA.bindEvents();
  }
});
