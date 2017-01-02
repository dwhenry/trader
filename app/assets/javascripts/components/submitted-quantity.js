(function($) {
  var submittedQuantity = $('.js-quantity-submitted');

  $('.js-quantity-update').on('change', function() {
    var direction = $('.js-direction:checked').val() === 'buy' ? 1 : -1;
    var quantity = parseInt($('.js-quantity').val());

    submittedQuantity.val(direction * quantity);
  })
})(jQuery);
