var loadAuthors = function() {
  $.ajax({
    url: '/modules/grunt.gruntfile/authors',
    success: function(data) {
      $('#authors').text(data.authors);
    }
  });
};

var loadConfig = function() {
  $.ajax({
    url: '/modules/grunt.gruntfile/config',
    success: function(data) {
      $('#config').text(data.config);
    }
  });
};

var loadLicense = function() {
  $.ajax({
    url: '/modules/grunt.gruntfile/license',
    success: function(data) {
      $('#license').text(data.license);
    }
  });
};

var loadReadme = function() {
  $.ajax({
    url: '/modules/grunt.gruntfile/readme',
    success: function(data) {
      $('#readme').text(data.readme);
    }
  });
};