describe('Plink.walletOffersManager', function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<script id="populated_wallet_item_template" type="text/x-handlebars-template"><div class="populated-wallet-item" data-reveal-id="some-modal" data-template-name="populated_wallet_item"></div></script>' +
        '<script id="locked_wallet_item_template" type="text/x-handlebars-template"><div class="locked-wallet-item"></div></script>' +
        '<script id="open_wallet_item_template" type="text/x-handlebars-template"><div class="open-wallet-item"></div></script>' +
        '<script id="offer_item_template" type="text/x-handlebars-template"><div class="offer">{{icon_description}}</div></script>' +
        '<div id="wallet_items_management">' +
        '<div id="wallet_items_bucket">' +
        '<div class="slot">empty slot</div>' +
        '<div class="slot">locked slot</div>' +
        '</div>' +
        '<div id="offers_bucket">' +
        '<div class="offer" id="first_offer" data-reveal-id="some-modal">Offer One</div>' +
        '</div>' +
        '<a data-add-to-wallet="true" data-offer-dom-selector="#first_offer">add to wallet</a>' +
        '<div id="some-modal" class="offer-details"></div>' +
        '</div>'
    );
    successfulResponse = {wallet: [
      {"template_name": "populated_wallet_item", "icon_url": "/assets/wallet-logos/arbys.png", "icon_description": "Arbys", "currency_name": "Plink points", "max_currency_award_amount": "1150", "wallet_offer_url": "http://localhost:3000/wallet/offers/22"},
      {"description": "Select an offer to start earning Plink points.", "icon_description": "Empty Slot", "icon_url": "/assets/icon_emptyslot.png", "template_name": "open_wallet_item", "title": "This slot is empty."},
      {"description": "Complete an offer to unlock this slot.", "icon_description": "Locked Slot", "icon_url": "/assets/icon_lockedslot.png", "template_name": "locked_wallet_item", "title": "This slot is locked."}
    ]};

    spyOn(window, 'setTimeout').andCallFake(function (callback) {
      callback();
    });

  });

  describe("on initialize", function () {
    it("identifies which modals are associated with offers in the wallet", function () {
      $('#wallet_items_bucket').append('<div class="populated-wallet-item" data-reveal-id="some-modal" data-template-name="populated_wallet_item"></div>');
      $('#wallet_items_management').append('<div id="other-modal" class="modal" data-in-wallet="true"></div>')

      $('#wallet_items_management').walletOffersManager();
      expect($("#some-modal[data-in-wallet]").length).toEqual(1);
      expect($("#other-modal[data-in-wallet]").length).toEqual(0);
    });

    it("enables all disabled removal buttons", function() {
      $('#wallet_items_bucket').append('<a data-remove-from-wallet="true" class="disabled">remove</a>');

      expect($("[data-remove-from-wallet].disabled").length).toEqual(1);
      $('#wallet_items_management').walletOffersManager();
      expect($("[data-remove-from-wallet].disabled").length).toEqual(0);
    });

  });

  describe("adding items to a wallet items bucket", function () {
    it("removes the item from the offers bucket", function () {
      var fakeResponse = successfulResponse;
      var fakejqXHR = {done: function (callback) {
        callback(fakeResponse);
        return fakejqXHR;
      }, error: jasmine.createSpy()};
      spyOn($, "ajax").andReturn(fakejqXHR);

      $('#wallet_items_management').walletOffersManager();
      expect($('#offers_bucket').find('.offer').length).toEqual(1);
      $('[data-add-to-wallet]').click();
      expect($('#offers_bucket').find('.offer').length).toEqual(0);
    });

    it("Adds the offer to the walletItemsBucket", function () {
      var fakeResponse = successfulResponse
      var fakejqXHR = {done: function (callback) {
        callback(fakeResponse);
        return fakejqXHR;
      }, error: jasmine.createSpy()};
      spyOn($, "ajax").andReturn(fakejqXHR);

      $('#wallet_items_management').walletOffersManager();
      expect($('#wallet_items_bucket').find('.populated-wallet-item').length).toEqual(0);
      $('[data-add-to-wallet]').click();
      expect($('#wallet_items_bucket').find('.populated-wallet-item').length).toEqual(1);
    })


    it("triggers the onSuccess event", function () {
      var fakeResponse = successfulResponse;
      var fakejqXHR = {done: function (callback) {
        callback(fakeResponse);
        return fakejqXHR;
      }, error: jasmine.createSpy()};
      spyOn($, "ajax").andReturn(fakejqXHR);

      var successFunction = jasmine.createSpy('successFunction');
      $('#wallet_items_management').on('success', successFunction);

      $('#wallet_items_management').walletOffersManager();
      $('[data-add-to-wallet]').click();
      expect(successFunction).toHaveBeenCalled();
    })

    describe("Failed add attempt", function () {
      beforeEach(function() {
        var fakeResponse = {responseText: JSON.stringify({failure_reason: 'fail'})};
        var fakejqXHR = {done: function (callback) {
          return fakejqXHR;
        }, error: function (callback) {
          callback(fakeResponse);
        }};
        spyOn($, "ajax").andReturn(fakejqXHR);
      });

      it("Doesn't remove the offer from the wall and triggers the on failure event", function () {
        var failureFunction = jasmine.createSpy('failureFunction').andCallFake(function (e, reason) {
          expect(reason).toEqual('fail');
        });

        $('#wallet_items_management').on('failure', failureFunction);

        $('#wallet_items_management').walletOffersManager();
        expect($('#offers_bucket').find('.offer').length).toEqual(1);

        $('[data-add-to-wallet]').click();
        expect($('#offers_bucket').find('.offer').length).toEqual(1);
        expect(failureFunction).toHaveBeenCalled();

      });

      it("hides the call to action button and displays the message", function () {
        $('#wallet_items_bucket').append('<div class="populated-wallet-item"><a href="#bla" data-remove-from-wallet=true>remove</a></div>');
        $('#some-modal').html('<a class="add-call-to-action">Do Something!</a><p class="reason fail hidden">This is the reason</p>');
        $('#wallet_items_management').walletOffersManager();

        expect($('.reason').hasClass('hidden')).toBeTruthy();
        expect($('.add-call-to-action').hasClass('hidden')).toBeFalsy();

        $('[data-add-to-wallet]').click();

        expect($('.reason').hasClass('hidden')).toBeFalsy();
        expect($('.add-call-to-action').hasClass('hidden')).toBeTruthy();



      });

    });
  });

  describe("removing an offer from the wallet", function () {
    beforeEach(function () {
      var fakeResponse = {wallet: [
        {"template_name": "populated_wallet_item", "icon_url": "/assets/wallet-logos/arbys.png", "icon_description": "Arbys", "currency_name": "Plink points", "max_currency_award_amount": "1150", "wallet_offer_url": "http://localhost:3000/wallet/offers/22"},
        {"description": "Select an offer to start earning Plink points.", "icon_description": "Empty Slot", "icon_url": "/assets/icon_emptyslot.png", "template_name": "open_wallet_item", "title": "This slot is empty."},
        {"description": "Complete an offer to unlock this slot.", "icon_description": "Locked Slot", "icon_url": "/assets/icon_lockedslot.png", "template_name": "locked_wallet_item", "title": "This slot is locked."}
      ],
        removed_wallet_item: {"template_name": "offer_item", "icon_url": "/assets/wallet-logos/arbys.png", "icon_description": "McDonalds", "currency_name": "Mcpoints", "max_currency_award_amount": "950", "wallet_offer_url": "http://localhost:3000/wallet/offers/13"}
      }
      var fakejqXHR = {done: function (callback) {
        callback(fakeResponse);
        return fakejqXHR;
      }, error: jasmine.createSpy()};
      spyOn($, "ajax").andReturn(fakejqXHR);
    });

    it("re-renders the wallet items bucket", function () {
      $('#wallet_items_management').walletOffersManager();
      $('#wallet_items_bucket').append('<div class="populated-wallet-item"><a href="#bla" data-remove-from-wallet=true>remove</a></div>');
      $('#wallet_items_bucket').append('<div class="populated-wallet-item"></div>');
      expect($('#wallet_items_bucket').find('.populated-wallet-item').length).toEqual(2);
      $('[data-remove-from-wallet]').click();
      expect($('#wallet_items_bucket').find('.populated-wallet-item').length).toEqual(1);
    });

    it("prepends the removed item to the offers bucket", function () {
      $('#wallet_items_bucket').append('<a href="#bla" data-remove-from-wallet=true>remove</a>');
      $('#wallet_items_management').walletOffersManager();
      expect($('#offers_bucket').find('.offer').length).toEqual(1);
      $('[data-remove-from-wallet]').click();
      expect($('#offers_bucket').find('.offer').length).toEqual(2);
      expect($('#offers_bucket').find('.offer').first().text()).toEqual('McDonalds');
    });

    it("hides the reason text and shows call to action", function () {
      $('#wallet_items_bucket').append('<div class="populated-wallet-item"><a href="#bla" data-remove-from-wallet=true>remove</a></div>');
      $('#some-modal').html('<a class="add-call-to-action hidden">Do Something!</a><p class="reason">This is the reason</p>');
      $('#wallet_items_management').walletOffersManager();

      expect($('.reason').hasClass('hidden')).toBeFalsy();
      expect($('.add-call-to-action').hasClass('hidden')).toBeTruthy();

      $('[data-remove-from-wallet]').click();
      expect($('.reason').hasClass('hidden')).toBeTruthy();
      expect($('.add-call-to-action').hasClass('hidden')).toBeFalsy();
    });


  });
});
