var SharePages = {
  init: function () {
    if ( $('#share_pages-show').length ) {
      SharePages.bindEvents();
      SharePages.createShareTrackingRecord();
    }
  },

  bindEvents: function () {
    $(document).on('click', '.js-decline-to-share', SharePages.trackShareDecline);
  },

  createShareTrackingRecord: function () {
    var url = $('#js-create-share-tracking-url').val();
    $.ajax({url: url});
  },

  trackShareDecline: function(event) {
    event.preventDefault();
    var url = $('#js-update-share-tracking-url').val();

    $.ajax({
      url: url,
      data: {shared: false}
    }).done(SharePages.redirectToWalletWithLinkCardModal);
  },

  redirectToWalletWithLinkCardModal: function() {
    Plink.redirect('/wallet?link_card=true');
  }
}
