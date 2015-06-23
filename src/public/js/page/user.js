var addCollection = function() {
  var form = new formulator(Crystal.Form.AddCollection);
  
  Crystal.Popup.show({
    title: 'Add Collection',
    content: form.toString()
  });
  
  return false;
};

var editCollection = function(o) {
  var form = new formulator(Crystal.Form.EditCollection, $(o).data());
  
  var deleteForm = new formulator(Crystal.Form.DeleteCollection, $(o).data());
  
  Crystal.Popup.show({
    title: 'Edit Collection',
    content: form.toString() + deleteForm.toString()
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