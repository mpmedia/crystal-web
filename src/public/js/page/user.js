var addCollection = function() {
  Crystal.Loader.show();
  
  new formulator({
    formula: '/formulas/forms/AddCollection.json',
    ready: function(form) {
      Crystal.Popup.show({
        title: 'Add Collection',
        content: form.toString()
      });
    }
  });
    
  return false;
};

var editCollection = function(o) {
  Crystal.Loader.show();
  
  new formulator({
    data: $(o).data(),
    formula: '/formulas/forms/EditCollection.json',
    ready: function(form) {
      Crystal.Popup.show({
        title: 'Edit Collection',
        content: form.toString()
      });
    }
  });
  
  return false;
};

var deleteCollection = function(id) {
  var form = new formulator(Crystal.Form.DeleteCollection, { id: id });
  
  Crystal.Popup.show({
    title: 'Delete Collection',
    content: form.toString()
  });
  
  return false;
};