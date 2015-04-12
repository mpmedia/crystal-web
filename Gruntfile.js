module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      options: {
        separator: ''
      },
      dist: {
        src: 'lib/css/**/*.css',
        dest: 'lib/public/css/main.css'
      }
    },
    copy: {
      main: {
        files: [
          {
            expand: true,
            cwd: 'src/code/views/',
            src: ['**'],
            dest: 'lib/views/',
            filter: 'isFile'
          }
        ]
      }
    },
    sass: {
      dist: {
        files: [{
          expand: true,
          cwd: 'src/code/sass',
          src: ['*.scss'],
          dest: 'lib/css',
          ext: '.css'
        }],
        options: {
          sourcemap: 'none',
          style: 'compressed'
        }
      }
    },
    watch: {
      files: ['src/code/sass/**/*.scss', 'src/code/views/**/*.jade'],
      tasks: ['sass', 'concat', 'copy']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['sass', 'concat', 'copy']);

};