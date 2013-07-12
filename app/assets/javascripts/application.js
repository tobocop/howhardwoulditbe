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
//= require_self
//= require_tree .

$(function () {
  Plink.boot();
});

var Plink = {
  redirect: function (path) {
    window.location.href = path;
  },

  boot: function () {
    $(document).foundation();

    Modernizr.load({
      test: Modernizr.input.placeholder,
      nope: '/assets/jquery.placeholder.js',
      callback: function () {
        $('input, textarea').placeholder();
      }
    });
  },

  conditionalCallback: function (flag, callback) {
    if (flag) {
      callback();
    }
  }
};

Plink.Config = {
  enabledProviders: 'facebook,twitter',
  enabledShareMethods: 'facebook-like,twitter-tweet'
}
