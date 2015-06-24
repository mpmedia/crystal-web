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