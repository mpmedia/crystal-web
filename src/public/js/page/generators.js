var search = function() {
  $('#results').empty();
  
  if (!$('input[name="search"]').val().length) {
    return;
  }
  
  $.ajax({
    method: 'GET',
    url: api + 'generators',
    success: function(data) {
      $('#results').empty();
      
      if (!$('input[name="search"]').val().length) {
        return;
      }
      
      var gen;
      for (var i in data) {
        if (i == 10) {
          break;
        }
        gen = data[i];
        $('#results').append('<a href="gen/' + gen.name + '.html">' + gen.name + '</a>')
      }
      
      console.log(data);
    }
  });
};