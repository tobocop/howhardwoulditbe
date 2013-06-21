var GigyaPostLoginHandler = {
  handleLogin: function (data) {
    if (data.user.loginProvider == 'twitter') {
      var email = encodeURIComponent(data.user.email);
      var uid = encodeURIComponent(data.user.UID);
      var firstName = encodeURIComponent(data.user.firstName);

      var url = "/handle_gigya_login?email=" + email + '&UID=' + uid + '&firstName=' + firstName;

      Plink.redirect(url);
    }
  }
}
