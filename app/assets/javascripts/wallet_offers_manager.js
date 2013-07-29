(function ($) {
  Plink.WalletOffersManager = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.init = function () {
      base.options = $.extend({}, Plink.WalletOffersManager.defaultOptions, options);
      base.successEvent = base.options.successEvent
      base.failureEvent = base.options.failureEvent
      base.offersBucket = new Plink.OffersBucket(base.$el.find('#offers_bucket'));
      base.walletItemsBucket = new Plink.WalletItemsBucket(base.$el.find('#wallet_items_bucket'));

      base.bindEvents();
      base.determineWalletOffers();
    };

    base.determineWalletOffers = function () {
      base._defer(function() {
        base.$el.find('[data-in-wallet]').removeAttr('data-in-wallet');
      });

      $(base.walletItemsBucket.getPopulatedWalletItems()).each(function (index, el) {
        var selector = '#' + $(el).data('reveal-id');
        base._defer(function () {
          base.$el.find(selector).attr('data-in-wallet', true);
        });
      });
    };

    base.bindEvents = function () {
      base.$el.on('click', '[data-add-to-wallet]', base._handleWalletAddClick);
      base.$el.on('click', '[data-remove-from-wallet]', base._handleWalletRemoveClick);
    };

    base._onSuccess = function () {
      base.$el.trigger(base.successEvent);
      base.determineWalletOffers();
    }

    base._onFailure = function (reason) {
      base.$el.trigger(base.failureEvent, reason);
    }

    base._handleWalletAddClick = function (e) {
      e.preventDefault();
      var $target = $(e.currentTarget);

      base._addItemToWallet($target);
    };

    base._handleWalletRemoveClick = function (e) {
      e.preventDefault();
      var $target = $(e.currentTarget);

      if (!$target.hasClass('disabled')) {
        $target.addClass('disabled');
        base._removeItemFromWallet($target);
      }

    };

    base._defer = function(callback) {
      setTimeout(callback, 1000);
    };

    base._addItemToWallet = function ($el) {
      var url = $el.attr('href');
      var offerSelector = $el.data('offer-dom-selector');
      base.sync(url, 'post', function(data) {
        base.offersBucket.remove(offerSelector);
      });
    };

    base._removeItemFromWallet = function ($el) {
      var url = $el.attr('href');
      base.sync(url, 'delete', function(data) {
        base.offersBucket.add(data.removed_wallet_item);
      });
    };

    base.sync = function (url, httpMethod, callback) {
      $.ajax(url, {
        method: httpMethod
      }).done(function (data) {
          if (!data.failure_reason) {

            base._onSuccess()

            base.walletItemsBucket.updateWalletItems(data.wallet);

            base.determineWalletOffers();

            callback(data);
          } else {
            base._onFailure(data.failure_reason)
          }
        });
    };

    base.init();
  };

  Plink.OffersBucket = function (el) {
    var base = this;

    base.$el = $(el);

    base.offerItemTemplate = Handlebars.compile($('#offer_item_template').html());

    base.init = function () {

    };

    base.add = function (offerData) {
      if (offerData) {
        base.$el.prepend(base.offerItemTemplate(offerData));
      }
    };

    base.remove = function (offerSelector) {
      base.$el.find(offerSelector).remove();
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
    };


    base.getPopulatedWalletItems = function () {
      return base.$el.find('[data-template-name="populated_wallet_item"]');
    };

    base.init();
  };


  Plink.WalletOffersManager.defaultOptions = {
    successEvent: 'success',
    failureEvent: 'failure'
  };

  $.fn.walletOffersManager = function (options) {
    return this.each(function () {
      (new Plink.WalletOffersManager(this, options));
    });
  };

})(jQuery);