var addAccount = function() {
  if (location.host == 'crystal.sh') {
    var client_id = 'b15727baac5a27dcec10';
    var redirect_uri = 'https://crystal.sh/accounts/connect/github';
  } else {
    var client_id = '1a72d9c6a9602772d577';
    var redirect_uri = 'http://alpha.crystal.sh:8080/accounts/connect/github';
  }
  
  Crystal.Popup.show({
    content: '<div align="center"><div><img height="200" src="/images/octocat.svg" /></div><a href="https://github.com/login/oauth/authorize?client_id=' + client_id + '&redirect_uri=' + redirect_uri + '&scope=user,public_repo">Connect GitHub Account</a></div>'
    /*+ '<div align="center"><a href="https://bitbucket.org/site/oauth2/authorize?client_id=ejHGb4Rk32jSPhUVmw&response_type=code">Connect Bitbucket Account</a></div>'*/
  });
  
  return false;
};

var addCollection = function() {
  Crystal.Loader.show();
  
  new formulator({
    formula: '/formulas/forms/AddCollection.json',
    xhr: true,
    ready: function(form) {
      form.data.color = Crystal.Color.random();
      form.fields.color.type = 'hidden';
      
      Crystal.Popup.show({
        title: 'Add Collection',
        content: '<div class="error"></div>' + form.toString()
      });
    },
    submit: function() {
      console.log('Loading...');
    },
    error: function(data) {
      $('#popup .error').show();
      $('#popup .error').text(data.error);
      $(window).resize();
    },
    success: function(data) {
      var li = $(document.createElement('li'));
      li.css({
        backgroundImage: 'url(' + url.img + 'collections/' + data.id + '.svg)',
        border: '10px #' + data.color + ' solid'
      });
      li.data(data);
      li.on('mouseenter', function() {
        this.style.backgroundColor = '#' + $(this).data('color');
      });
      li.on('mouseleave', function() {
        this.style.backgroundColor = '#FFF';
      });
      li.html('<a class="view" href="collections/' + data.name + '"></a><a href="#" onclick="return editCollection($(this).parent()[0])" class="edit"></a><a href="#" onclick="return deleteCollection($(this).parent().data(&quot;id&quot;))" class="delete"></a>');
      $('#collections li').last().before(li);
      Crystal.Popup.hide();
    }
  });
    
  return false;
};

var addModule = function() {
  Crystal.Loader.show();
  
  new formulator({
    formula: '/formulas/forms/AddModule.json',
    xhr: true,
    ready: function(form) {
      $.when(
        $.ajax({
          url: '/accounts',
          dataType: 'json'
        }),
        $.ajax({
          url: '/collections',
          dataType: 'json'
        }),
        $.ajax({
          url: '/repositories',
          dataType: 'json'
        })
      ).done(function(accounts, collections, repositories) {
        accounts = accounts[0];
        collections = collections[0];
        repositories = repositories[0];
        
        form.fields.account.options = {}
        for (var i in accounts) {
          form.fields.account.options[accounts[i].id] = accounts[i].login;
        }
        
        form.fields.collection.options = {}
        for (var i in collections) {
          form.fields.collection.options[collections[i].id] = collections[i].name;
        }
        
        form.fields.repository.options = {}
        for (var i in repositories) {
          form.fields.repository.options[repositories[i].uuid] = repositories[i].url;
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
      $('#popup .error').show();
      $('#popup .error').text('Unable to add module');
      $(window).resize();
    },
    success: function(data) {
      $('#modules a').last().before('<a href="#" style="background-color: #' + data.color + '">' + data.name + '</a>');
      Crystal.Popup.hide();
    }
  });
    
  return false;
};

var editCollection = function(o) {
  Crystal.Loader.show();
  
  new formulator({
    action: '/collections',
    data: $(o).data(),
    formula: '/formulas/forms/EditCollection.json',
    method: 'patch',
    xhr: true,
    ready: function(form) {
      Crystal.Popup.show({
        title: 'Edit Collection',
        content: '<div class="error"></div>' + form.toString()
      });
    },
    submit: function() {
      console.log('Loading...');
    },
    error: function(data) {
      $('#popup .error').show();
      $('#popup .error').text('Unable to update collection');
      $(window).resize();
    },
    success: function(data) {
      var li = $('#collections li:data(id==' + data.id + ')');
      li.data(data);
      li.css('backgroundImage', 'url(' + url.img + 'collections/' + data.id + '.svg)');
      li.find('a.view').prop('href', 'collections/' + data.name);
      Crystal.Popup.hide();
    }
  });
  
  return false;
};

var deleteCollection = function(id) {
  new formulator({
    action: '/collections',
    formula: '/formulas/forms/DeleteCollection.json',
    method: 'delete',
    xhr: true,
    ready: function(form) {
      form.fields.name.match = 'coffeescript';
      
      Crystal.Popup.show({
        title: 'Delete Collection',
        content: '<div class="error"></div>' + form.toString()
      });
    },
    submit: function() {
      console.log('Loading...');
    },
    error: function(data) {
      $('#popup .error').show();
      $('#popup .error').text(data.error);
      $(window).resize();
    },
    success: function(data) {
      $('#collections li[data-id=' + data.id + ']').remove();
      Crystal.Popup.hide();
    }
  }, { id: id });
  
  return false;
};