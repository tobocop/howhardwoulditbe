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
      base.$el.on('click', '[data-remove-from-wallet]', base._handleWalletRemoveClick);
    };

    base._handleWalletAddClick = function (e) {
      e.preventDefault();
      var $target = $(e.currentTarget);

      base._addItemToWallet($target);
    };

    base._handleWalletRemoveClick = function (e) {
      e.preventDefault();
      var $target = $(e.currentTarget);

      base._removeItemFromWallet($target);
    };

    base._addItemToWallet = function ($el) {
      // add stuff to the wallet
      var url = $el.attr('href');
      base.sync(url, 'post');

      // removal from offers bucket
      var offer = base.offersBucket.findOffer($el.data('offer-dom-selector'));
      base.offersBucket.remove(offer);
    };

    base._removeItemFromWallet = function ($el) {
      var url = $el.attr('href');
      base.sync(url, 'delete');
    };

    base.sync = function (url, httpMethod) {
      $.ajax(url, {
        method: httpMethod
      }).done(function (data) {
        base.walletItemsBucket.updateWalletItems(data.wallet);
        base.offersBucket.add(data.removed_wallet_item);
      });
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

    base.offerItemTemplate = Handlebars.compile($('#offer_item_template').html());

    base.init = function () {

    };

    base.add = function(offerData) {
      if (offerData) {
        base.$el.prepend(base.offerItemTemplate(offerData));
      }
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