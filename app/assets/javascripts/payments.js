jQuery(function($) {
  $('#payment-form').submit(function(event) {
    var $form = $(this);
    $form.find('.btn').prop('disabled', true);
    Stripe.card.createToken($form, stripeResponseHandler);
    return false;
  });
});

function stripeResponseHandler(status, response) {
  var $form = $('#payment-form');

  if (response.error) {
    $form.find('.payment-errors').text(response.error.message);
    $form.find('.payment-alert').removeClass('hidden')
    $form.find('.btn').prop('disabled', false);
  }
  else {
    var token = response.id;
    $form.append($('<input type="hidden" name="stripeToken" />').val(token));
    $form.get(0).submit();
  }
};
