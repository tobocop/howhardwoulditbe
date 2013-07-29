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
//= require handlebars
//= require bjqs-1.3
//= require foundation/foundation
//= require foundation/foundation.reveal
//= require custom.modernizr
//= require_self
//= require notice
//= require_tree .

$(function () {
  Plink.boot();
});

var Plink = {
  redirect: function (path) {
    window.location.href = path;
  },

  boot: function () {

    $('body').positionFoundationModal({selector: '[data-reveal-id]'})

    $(document).foundation('reveal', {animationSpeed: 100});

    Modernizr.load({
      test: Modernizr.input.placeholder,
      nope: '/assets/jquery.placeholder.js',
      callback: function () {
        $('input, textarea').placeholder();
      }
    });

    $('#wallet_offers_management').walletOffersManager({
      successEvent: Plink.WalletEvents.successfulAdd,
      failureEvent: Plink.WalletEvents.failure
    }).on(Plink.WalletEvents.successfulAdd, function (e) {
      $('.modal.offer-details').each(function() {
        if ($(this).hasClass('open')) {
          $(this).foundation('reveal', 'close');
        }
      });
    });

    $('[data-account-edit-form]').accountEditForm();

    $('#organic-registration-form').ajaxRedirectForm();
    $('#organic-sign-in-form').ajaxRedirectForm();

    $('[data-toggle-selector]').toggler();

  },

  conditionalCallback: function (flag, callback) {
    if (flag) {
      callback();
    }
  }
};

Plink.Config = {
  enabledProviders: 'facebook,twitter',
  enabledShareMethods: [
    {
      provider: 'facebook-like',
      url: 'https://www.facebook.com/plinkdotcom',
      action: 'like'
    }
  ]
}

Plink.WalletEvents = {
  successfulAdd: 'successfulAdd',
  failure: 'failure'
}

