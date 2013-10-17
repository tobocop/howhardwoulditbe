describe('SharePages', function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<div id="share_pages-show">' +
        '<input id="js-create-share-tracking-url" type="hidden" value="create-url">' +
        '<input id="js-update-share-tracking-url" type="hidden" value="update-url">' +
        '<a href="#" class="js-decline-to-share">Decline</a>' +
      '</div>'
    );
  });

  describe('#init', function () {
    it('calls to bind DOM events', function () {
      spy = spyOn(SharePages, 'bindEvents');

      SharePages.init();

      expect(spy).toHaveBeenCalled();
    });

    it('calls to create a share tracking record', function () {
      spy = spyOn(SharePages, 'createShareTrackingRecord');

      SharePages.init();

      expect(spy).toHaveBeenCalled();
    });
  });

  describe('#bindEvents', function () {
    it('adds a click event to the decline link', function () {
      spy = spyOn(SharePages, 'trackShareDecline');

      SharePages.bindEvents();
      $('.js-decline-to-share').trigger('click');

      expect(spy).toHaveBeenCalled();
    });
  });

  describe('#createShareTrackingRecord', function () {
    it('makes an AJAX request', function (){
      spyOn($, "ajax");

      SharePages.createShareTrackingRecord();

      var url = $('#js-create-share-tracking-url').val();
      expect($.ajax).toHaveBeenCalledWith({url: url});
    });
  });

  describe('#trackShareDecline', function () {
    beforeEach(function () {
      mock_click_event = {type: 'click', preventDefault: function () {}};
    });

    it('makes an AJAX request', function () {
      spyOn($, "ajax").andCallFake(function() {return $.Deferred();});

      SharePages.trackShareDecline(mock_click_event);

      var url = $('#js-update-share-tracking-url').val();
      expect($.ajax).toHaveBeenCalledWith({url: url, data: {shared: false}});
    });

    it('makes a call to redirectToWalletWithLinkCardModal', function () {
      spyOn($, "ajax").andCallFake(function() {return $.Deferred().resolve();});
      spy = spyOn(SharePages, 'redirectToWalletWithLinkCardModal');

      SharePages.trackShareDecline(mock_click_event);

      expect(spy).toHaveBeenCalled();
    });
  });
});
