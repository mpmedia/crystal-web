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

$(window).load(function() {
  $('body').css('backgroundImage', 'url(https://s3.amazonaws.com/crystal-web/img/quartz.jpg)');
  
  setInterval(function() {
    if ($(window).width() < 640) {
      return;
    }
    
    var data, padding, type = $('header').data('type');
    
    if ($(window).scrollTop() <= $('header').height() - 50) {
      if (type == 'expand') {
        return;
      }
      color = '';
      data = 'expand'
      padding = 40;
      
    } else {
      if (type == 'collapse') {
        return;
      }
      color = '#000';
      data = 'collapse'
      padding = 10;
    }
    
    if (type == 'collapse') {
      $('header').css('backgroundColor', color);
    }
    $('header').data('type', data);
    $('header').stop().animate({
      padding: padding
    },{
      complete: function() {
        if (type == 'expand') {
          $('header').css('backgroundColor', color);
        }
        $('header').removeData('animating');
      }
    });
    
  }, 100);
  
  $(window).scroll(function() {
    if ($(window).width() < 640) {
      return;
    }
    
    var opacity = 1 - ($(window).scrollTop() / ($('header').outerHeight() + 80));
    if (opacity < 0) {
      opacity = 0;
    }
    $('#intro').css('opacity', opacity);
    if (opacity === 0) {
      $('#intro div').hide();
    } else {
      $('#intro div').show();
    }
  });
  
  setInterval(function() {
    var search_term = search_terms[search_i];
    $('#search-term').attr('href', '/gen/' + search_term);
    $('#search-term').text(search_term);
    
    if (search_i == search_terms.length-1) {
      search_i = 0;
    } else {
      search_i++;
    }
    
  }, 2000);
  
  $('.image').on('mouseenter', function() {
    $(this).find('.screenshot').css('width', $(this).find('.icon').outerWidth()).fadeIn();
  });
  $('.image').on('mouseleave', function() {
    $(this).find('.screenshot').fadeOut();
  });
  
  $('#generator button').click(function() {
    var json = jsyaml.safeLoad(editor.getDoc().getValue());
    
    $.ajax({
      data: JSON.stringify(json),
      method: 'post',
      url: url.api + 'generate',
      contentType: 'application/json; charset=utf-8',
      dataType: 'json',
      success: function(data) {
        $('#tabs').empty();
        if (output) {
          output.getDoc().setValue('');
        }
        
        var i = 0;
        for (var file_name in data.files) {
          if (i == 0) {
            if (!output) {
              output = CodeMirror.fromTextArea($('#output textarea')[0]);
            }
            var file_type;
            switch (true) {
              case file_name.match(/\.coffee$/) !== null:
                file_type = 'coffeescript';
                break;
              case file_name.match(/\.js$/) !== null:
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
          file_name = file_name.substr(2);
          $('#tabs').append('<a href="#">' + file_name + '</a>');
        }
      }
    });
  });
  
  var editor = CodeMirror.fromTextArea($('#input textarea')[0], {
    mode: 'yaml'
  });
  
  $('#input select').on('change', function() {
    editor.getDoc().setValue(jsyaml.safeDump(configs[$(this).val()], null, "  "));
    $('#generator button').click();
  });
  
  $('#input select').val('readme').change();
  
  $(window).scroll();
});