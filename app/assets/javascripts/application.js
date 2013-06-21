// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bjqs-1.3
//= require foundation/foundation
//= require foundation/foundation.reveal
//= require custom.modernizr
//= require_tree .

$(function () {
  $(document).foundation();

  Modernizr.load({
    test: Modernizr.input.placeholder,
    nope: '/assets/jquery.placeholder.js',
    callback: function () {
      $('input, textarea').placeholder();
    }
  });
});


var GigyaPostLoginHandler = {
  handleLogin: function (data) {
    if (data.user.loginProvider == 'twitter') {
      console.log('should redirect');

      var email = encodeURIComponent(data.user.email);
      var uid = encodeURIComponent(data.user.UID);
      var firstName = encodeURIComponent(data.user.firstName);

      var url = "/handle_gigya_login?email=" + email + '&UID=' + uid + '&firstName=' + firstName;

      console.log(url);

      Plink.redirect(url);
    } else {
      console.log('used facebook');
    }
  }
}

var Plink = {
  redirect: function (path) {
    window.location.href = path;
  }
};

