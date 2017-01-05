(function($) {
  $.each($('.js-ajax-load'), function(i, element) {
    var $element = $(element);

    $.ajax({
      url: $element.data('url'),
      cache: false,
      success: function(html) {
        $element.html(html);
      }
    });
  });
})(jQuery);


