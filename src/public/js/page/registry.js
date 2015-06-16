$(window).load(function() {
  $('article').hide();
  $('section nav a').click(function() {
    $('section nav a').removeClass('selected');
    $(this).addClass('selected');
    
    $('article').hide();
    $($(this).attr('href')).show();
    
    return false;
  });
  
  $('section nav a').first().click();
});