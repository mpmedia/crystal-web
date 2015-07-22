function hideOptions(o, cls) {
  o.parent().parent().find('a').removeClass('selected');
  o.addClass('selected');
  o.parents('div').first().find('a').first().animate({ marginTop: 0 });
  o.parents('div').first().removeClass();
  o.parents('div').first().addClass(cls);
};

function showOptions(o) {
  o.animate({ marginTop: -o.outerHeight() });
  o.parents('div').addClass('selected');
};

$(window).resize(function() {
  $('ul.choose div').css({
    height: $('ul.choose div').outerWidth() + 'px'
  });
});

$(window).load(function() {
  $('ul.choose a').click(function() {
    var o = $(this);
    switch (o.attr('href')) {
      case 'download/platform': {
        showOptions(o);
        break;
      }
      case 'download/platform/mac': {
        hideOptions(o, 'apple');
        break;
      }
      case 'download/platform/linux': {
        hideOptions(o, 'linux');
        break;
      }
      case 'download/platform/windows': {
        hideOptions(o, 'windows');
        break;
      }
      case 'download/provider': {
        showOptions(o, 'provider');
        break;
      }
      case 'download/provider/github': {
        hideOptions(o, 'github');
        break;
      }
      case 'download/provider/homebrew': {
        hideOptions(o, 'homebrew');
        break;
      }
      case 'download/provider/npm': {
        hideOptions(o, 'npm');
        break;
      }
      case 'download/version': {
        showOptions(o);
        break;
      }
      case 'download/version/v0.6': {
        hideOptions(o);
        break;
      }
      case 'download/version/v0.5': {
        hideOptions(o);
        break;
      }
      case 'download/version/v0.4': {
        hideOptions(o);
        break;
      }
    }
    return false;
  });
  
  $(window).resize();
});