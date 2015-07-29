var addModule = function() {
  Crystal.Loader.show();
  
  new formulator({
    formula: '/formulas/forms/AddModule.json',
    xhr: true,
    ready: function(form) {
      $.when(
        $.ajax({
          url: url.web + 'accounts',
          dataType: 'json'
        }),
        $.ajax({
          url: url.web + 'collections',
          dataType: 'json'
        }),
        $.ajax({
          url: url.web + 'repositories',
          dataType: 'json'
        })
      ).done(function(accounts, collections, repositories) {
        accounts = accounts[0];
        collections = collections[0];
        repositories = repositories[0];
        
        form.fields.account.options = [];
        for (var i in accounts) {
          form.fields.account.options.push({
            text: accounts[i].login,
            value: accounts[i].id
          });
        }
        
        form.data.collection = collectionId;
        form.fields.collection.options = [];
        for (var i in collections) {
          form.fields.collection.options.push({
            text: collections[i].name,
            value: collections[i].id
          });
        }
        
        form.fields.repository.options = [];
        for (var i in repositories) {
          form.fields.repository.options.push({
            text: repositories[i].url,
            value: repositories[i].uuid
          });
        }
        
        Crystal.Popup.show({
          title: 'Add Module',
          content: form.toString()
        });
      });
    },
    submit: function() {
      console.log('Loading...');
    },
    error: function(data) {
      $('#popup .error').text('Unable to update module');
      $(window).resize();
    },
    success: function(data) {
      var li = $(document.createElement('li'));
      var a = $(document.createElement('a'));
      a.prop('data-id', data.id);
      a.prop('data-description', data.description);
      a.prop('data-name', data.name);
      a.prop('href', '#');
      a.append('<span class="name">' + data.name + '</span>');
      a.append('<span class="description">' + data.description + '</span>');
      a.append('<span class="user">by ' + data.User.username + '</span>');
      li.append(a);
      
      $('#modules li').last().before(li);
      Crystal.Popup.hide();
    }
  });
    
  return false;
};

var addFavorite = function() {
  window.location.href = '/login';
  return false;
  
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

var viewModule = function(o) {
  var data = $(o).data();
  
  Crystal.Popup.show({
    content: '<h1>' + data.module + '.' + data.name + '</h1>'
      + '<div style="padding-bottom: 20px">' + data.description + '</div>'
      + '<div style="padding-bottom: 20px">'
        + '<a href="https://github.com/' + data.repository + '" target="_blank">'
          + '<img height="16" src="/images/github-account.svg" /> ' + data.repository
        + '</a>'
      + '</div>'
      + '<code style="white-space: nowrap">crystal install ' + data.module + '.' + data.name + '</code>'
      + '<div id="loader">Loading...</div>'
  });
  
  $.ajax({
    url: '/modules/' + data.name,
    success: function(data) {
      var releases = '';
      for (var i in data.releases) {
        releases += '<li>' + data.releases[i].tag + '</li>';
      }
      
      $('#loader').replaceWith(
          '<ul id="tabs">'
          + '<li><a href="#">Exports</a></li>'
          + '<li><a href="#">Releases</a></li>'
          + '<li><a href="#">Config</a></li>'
        + '</ul>'
        + '<ul id="tab">'
          + releases
        + '</ul>'
      );
    }
  });
  
  return false;
};