var addAccount = function() {
  Crystal.Popup.show({
    content: '<div align="center"><a href="https://github.com/login/oauth/authorize?client_id=1a72d9c6a9602772d577&redirect_uri=http://alpha.crystal.sh:8080/accounts/connect/github&scope=user,public_repo">Connect GitHub Account</a></div><div align="center"><a href="https://bitbucket.org/site/oauth2/authorize?client_id=ejHGb4Rk32jSPhUVmw&response_type=code">Connect Bitbucket Account</a></div>'
  });
  
  return false;
};

var addCollection = function() {
  Crystal.Loader.show();
  
  new formulator({
    formula: '/formulas/forms/AddCollection.json',
    xhr: true,
    ready: function(form) {
      Crystal.Popup.show({
        title: 'Add Collection',
        content: form.toString()
      });
    },
    submit: function() {
      console.log('Loading...');
    },
    error: function(data) {
      $('#popup .error').text('Unable to update collection');
      $(window).resize();
    },
    success: function(data) {
      $('#collections a').last().before('<a href="#" style="background-color: #' + data.color + '">' + data.name + '</a>');
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
      $('#popup .error').text('Unable to update module');
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
        content: '<div class="error"></div>' + form.toString() + '<button onclick="return deleteCollection(' + $(o).data('id') + ')">Delete Collection</button>'
      });
    },
    submit: function() {
      console.log('Loading...');
    },
    error: function(data) {
      $('#popup .error').text('Unable to update collection');
      $(window).resize();
    },
    success: function(data) {
      $('#collections a[data-id=' + data.id + ']').data('name', data.name);
      $('#collections a[data-id=' + data.id + ']').text(data.name);
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
      Crystal.Popup.show({
        title: 'Delete Collection',
        content: '<div class="error"></div>' + form.toString()
      });
    },
    submit: function() {
      console.log('Loading...');
    },
    error: function(data) {
      $('#popup .error').text('Unable to delete collection');
      $(window).resize();
    },
    success: function(data) {
      $('#collections a[data-id=' + data.id + ']').remove();
      Crystal.Popup.hide();
    }
  }, { id: id });
  
  return false;
};