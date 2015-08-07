var configs = {
  custom: {
    name: 'my.app',
    version: '1.0.0',
    description: 'My application.',
    modules: {},
    imports: {},
    outputs: []
  },
  
  authors: {
    modules: {
      'authors.file': 'latest'
    },
    imports: {
      authors: 'authors.file.Generator'
    },
    outputs: [{
      generator: 'authors',
      spec: {
        author: {
          name: 'Crystal',
          email: 'support@crystal.sh',
          url: 'https://crystal.sh'
        },
        name: 'Crystal'
      }
    }]
  },
  
  express: {
    modules: {
      'express.app': 'latest',
      'express.route': 'latest'
    },
    imports: {
      'express-app': 'express.app.Generator',
      'express-route': 'express.route.Generator'
    },
    outputs: [{
      generator: 'express-app',
      spec: {
        port: 8080
      }
    }]
  },
  
  gruntfile: {
    modules: {
      'grunt.file': 'v0.1.0'
    },
    imports: {
      grunt: 'grunt.file.Generator'
    },
    outputs: [{
      generator: 'grunt',
      spec: {
        loadNpmTasks: [
          'grunt-contrib-sass',
          'grunt-contrib-watch'
        ],
        registerTask: {
          'default': 'sass'
        },
        config: {
          pkg: 'package.json',
          sass: {
            dist: {
              files: {
                expand: true,
                cwd: 'src/sass',
                src: [
                  '**/*.scss'
                ],
                dest: 'src/public/css',
                ext: '.css'
              },
              options: {
                sourcemap: 'none',
                style: 'compressed'
              }
            }
          },
          watch: {
            files: 'src/sass/**/*.scss',
            task: 'sass'
          }
        }
      }
    }]
  },
  
  license: {
    modules: {
      'license.mit': 'latest'
    },
    imports: {
      license: 'license.mit.Generator'
    },
    outputs: [{
      generator: 'license',
      spec: {
        copyright: '2015 Crystal'
      }
    }]
  },
  
  php: {
    modules: {
      'php.config': 'latest'
    },
    imports: {
      php: 'php.config.Generator'
    },
    outputs: [{
      generator: 'php',
      spec: {
        register_globals: true
      }
    }]
  },
  
  readme: {
    modules: {
      'readme.md': 'latest'
    },
    imports: {
      readme: 'readme.md.Generator'
    },
    outputs: [{
      generator: 'readme',
      spec: {
        name: 'Hello, World!',
        description: 'Nice to meet you!'
      }
    }]
  },
  
  sequelize: {
    modules: {
      'sequelize.model': 'latest'
    },
    imports: {
      sequelize: 'sequelize.model.Generator'
    },
    outputs: [{
      generator: 'sequelize',
      spec: {
        models: [{
          name: 'post',
          attributes: {
            content: {
              required: true,
              type: 'string'
            }
          }
        }]
      }
    }]
  }
};

var search_i = 0;
var search_terms = [
  'laravel',
  'datamapper',
  'pip',
  'authors',
  'gorm',
  'readme',
  'sinatra',
  'ormlite',
  'gorp',
  'django'
];

var output;
var files;

$(window).load(function() {
  $('#output button').click(function() {
    var button = $(this);
    
    button.prop('disabled', 'disabled');
    button.text('Loading...');
    
    try {
      var json = jsyaml.safeLoad(editor.getDoc().getValue());
    } catch (e) {
      $('#error').show();
      $('#error').text(e);
      $(window).resize();
    }
    
    $.ajax({
      data: JSON.stringify(json),
      method: 'post',
      url: url.api + 'generate',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      error: function(data) {
        $('#error').show();
        $('#error').text('Invalid configuration.');
        $(window).resize();
      },
      success: function(data) {
        $('#tabs').empty();
        if (output) {
          output.getDoc().setValue('');
        }
        
        files = data.files;
        
        var i = 0;
        for (var file_name in data.files) {
          if (i == 0) {
            var file_type;
            switch (true) {
              case file_name.match(/\.coffee$/) !== null:
                file_type = 'coffeescript';
                break;
              case file_name.match(/\.js$/) !== null || file_name.match(/\.json$/) !== null:
                file_type = 'javascript';
                break;
              case file_name.match(/\.md$/) !== null:
                file_type = 'markdown';
                break;
              case file_name.match(/\.php$/) !== null:
                file_type = 'php';
                break;
              default:
                file_type = 'markdown';
                break;
            }
            output.setOption('mode', file_type);
            output.getDoc().setValue(data.files[file_name]);
            i++;
          }
          $('#tabs').append('<option>' + file_name + '</option>');
        }
        
        button.prop('disabled', null);
        button.text('Generate');
      }
    });
  });
  
  var editor = CodeMirror.fromTextArea($('#input textarea')[0], {
    //lineNumbers: true,
    mode: 'yaml',
    theme: 'mdn-like'
  });
  
  var output = CodeMirror.fromTextArea($('#output textarea')[0], {
    //lineNumbers: true,
    readOnly: true,
    theme: 'mdn-like'
  });
  
  $('#input select').on('change', function() {
    editor.getDoc().setValue(jsyaml.safeDump(configs[$(this).val()], null, "  "));
    $('#output button').click();
  });
  
  $('#input select').val('readme').change();
  
  $('#output select').on('change', function() {
    var file_name = $(this).val();
    
    var file_type;
    switch (true) {
      case file_name.match(/\.coffee$/) !== null:
        file_type = 'coffeescript';
        break;
      case file_name.match(/\.js$/) !== null || file_name.match(/\.json$/) !== null:
        file_type = 'javascript';
        break;
      case file_name.match(/\.md$/) !== null:
        file_type = 'markdown';
        break;
      case file_name.match(/\.php$/) !== null:
        file_type = 'php';
        break;
      default:
        file_type = 'markdown';
        break;
    }
    output.setOption('mode', file_type);
    output.getDoc().setValue(files[file_name]);
  });
  
  $('.help').click(function(e) {
    e.preventDefault();
    
    $('.hint').show();
  });
  
  $('.cson, .json, .yaml, .xml').click(function(e) {
    e.preventDefault();
    
    var data = {};
    switch (true) {
      case $('#formats .selected').children('.cson').length == 1:
        data = cson.load(
          editor.getDoc().getValue()
        );
        break;
      case $('#formats .selected').children('.json').length == 1:
        data = JSON.parse(
          editor.getDoc().getValue()
        );
        break;
      case $('#formats .selected').children('.yaml').length == 1:
        data = jsyaml.safeLoad(
          editor.getDoc().getValue()
        );
        break;
      case $('#formats .selected').children('.xml').length == 1:
        data = xml.load(
          editor.getDoc().getValue()
        );
        break;
    }
    
    var value = '';
    switch (true) {
      case $(this).hasClass('cson'):
        value = cson.dump(data);
        break;
      case $(this).hasClass('json'):
        value = JSON.stringify(data, null, '  ');
        break;
      case $(this).hasClass('yaml'):
        value = jsyaml.safeDump(data);
        break;
      case $(this).hasClass('xml'):
        value = cson.dump(data);
        break;
    }
    
    $('.cson, .json, .yaml, .xml').parent().removeClass('selected');
    $(this).parent().addClass('selected');
    
    editor.getDoc().setValue(value);
  });
  
  /*
  Crystal.Popup.show({
    title: 'Welcome to the Crystal Console',
    content: ''
  });
  */
  $('#error').hide();
  $(window).resize();
});

$(document).keydown(function(e) {
  $('#error').hide();
  $(window).resize();
  
  if (e.keyCode == 71 && e.ctrlKey) {
    $('#output button').click();
  }
});

$(window).resize(function() {
  $('textarea, .CodeMirror').css({
    height: $(window).height() - ($('#error').is(':visible') ? $('#error').outerHeight() : 0) - $('header').outerHeight() - $('.options').outerHeight() - $('#settings').outerHeight()
  });
});