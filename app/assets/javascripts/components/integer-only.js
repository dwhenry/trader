(function($) {
  $('body').on('input', 'input.integer-only', function() {
    this.value = this.value.replace(/[^0-9]/g,'');
  });
})(jQuery);


