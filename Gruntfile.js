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
      files: ['src/code/sass/**/*.scss'],
      tasks: ['sass', 'concat']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['sass', 'concat']);

};