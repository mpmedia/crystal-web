var addFavorite = function() {
  var heart = $('.heart');
  
  if (heart.hasClass('selected')) {
    heart.removeClass('selected');
    heart.css('backgroundImage', 'url(/images/heart-unselected.svg)');
    heart.css('color', '#000');
  } else {
    heart.addClass('selected');
    heart.css('backgroundImage', 'url(/images/heart-selected.svg)');
    heart.css('color', '#FFF');
  }
  
  heart.bind('mouseleave', function() {
    $(this).unbind('mouseleave');
    heart.css('backgroundImage', '');
    heart.css('color', '');
  });
  
  $.post(
    location.pathname + '/favorite',
    { favorite: heart.hasClass('selected') ? true : false },
    function(data) {
      $('.heart').text(data.favorites);
    }
  );
  
  return false;
};