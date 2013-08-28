var Redemption = {
  init: function() {
    if ( $('#rewards-index').length ) {
      Redemption.bindEvents();
    }
  },

  bindEvents: function(){
    $(".reward-amount-confirmation .confirm .button").click(Redemption.submit);
  },

  submit: function() {
    var reward_amount_id = $(this).data().rewardAmountId,
        data = $(this).closest('form').serialize() + '&reward_amount_id=' + reward_amount_id;

    $.ajax({
      url: '/redemption',
      method: 'POST',
      data: data,
      success: function(response) {
        $('body').html(response);
      }
    })

    return false;
  }
}
