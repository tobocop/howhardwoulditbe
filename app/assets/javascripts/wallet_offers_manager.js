(function ($) {
  Plink.WalletOffersManager = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.init = function () {
      base.options = $.extend({}, Plink.WalletOffersManager.defaultOptions, options);
      base.offersBucket = new Plink.OffersBucket(base.$el.find('#offers_bucket'));
      base.walletItemsBucket = new Plink.WalletItemsBucket(base.$el.find('#wallet_items_bucket'));

      base.bindEvents();
    };

    base.bindEvents = function () {
      base.$el.on('click', '[data-add-to-wallet]', base._handleWalletAddClick);
    };

    base._handleWalletAddClick = function (e) {
      e.preventDefault();
      var $target = $(e.currentTarget);

      base._addItemToWallet($target);
    };

    base._addItemToWallet = function ($el) {
      // add stuff to the wallet
      var url = $el.attr('href'); //parents('form').attr('action');
      base.walletItemsBucket.refreshOffers(url);

      // removal from offers bucket
      var offer = base.offersBucket.findOffer($el.data('offer-dom-selector'));
      base.offersBucket.remove(offer);
    };

    base.init();
  };


  Plink.Offer = function (el) {
    var base = this;

    base.$el = $(el);

    base.init = function () {
    };

    base.init();
  };


  Plink.OffersBucket = function (el) {
    var base = this;

    base.$el = $(el);

    base.init = function () {

    };

    base.remove = function (offer) {
      offer.$el.remove();
    };

    base.findOffer = function (selector) {
      return new Plink.Offer(base.$el.find(selector));
    };

    base.init();
  };


  Plink.WalletItemsBucket = function (el) {
    var base = this;

    base.$el = $(el);

    base.populatedWalletItemTemplate = Handlebars.compile($('#populated_wallet_item_template').html());
    base.openWalletItemTemplate = Handlebars.compile($('#open_wallet_item_template').html());
    base.lockedWalletItemTemplate = Handlebars.compile($('#locked_wallet_item_template').html());

    base.init = function () {

    };

    base.refreshOffers = function (url) {
      $.ajax(url, {
        method: 'post'
      }).done(base.updateWalletItems);
    };

    base.updateWalletItems = function (walletItems) {
      var walletItemsHTML = '';
      $(walletItems).each(function (i, walletItem) {
        if (walletItem.template_name == 'populated_wallet_item') {
          walletItemsHTML += base.populatedWalletItemTemplate(walletItem);
        } else if (walletItem.template_name == 'locked_wallet_item') {
          walletItemsHTML += base.lockedWalletItemTemplate(walletItem);
        } else {
          walletItemsHTML += base.openWalletItemTemplate(walletItem);
        }

      });
      base.$el.html(walletItemsHTML);
    }

    base.init();
  };


  Plink.WalletOffersManager.defaultOptions = {

  };

  $.fn.walletOffersManager = function (options) {
    return this.each(function () {
      (new Plink.WalletOffersManager(this, options));
    });
  };

})(jQuery);