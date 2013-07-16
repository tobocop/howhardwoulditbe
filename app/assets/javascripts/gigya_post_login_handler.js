(function (exports) {

  exports.Plink.GigyaPostLoginHandler = {
    handleLogin: function (data) {
      var twitterProvider = 'twitter'

      if (data.user.loginProvider == twitterProvider) {
        var email = encodeURIComponent(data.user.email);
        var uid = encodeURIComponent(data.user.UID);
        var firstName = encodeURIComponent(data.user.firstName);

        var url = "/handle_gigya_login?email=" + email + '&UID=' + uid + '&firstName=' + firstName + '&provider=' + twitterProvider;

        Plink.redirect(url);
      }
    }
  }
})(window);
