module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
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
        ],
        files: [
          {
            expand: true,
            cwd: 'src/code/public/js/',
            src: ['**'],
            dest: 'lib/public/js/',
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
          src: ['**/*.scss'],
          dest: 'lib/public/css',
          ext: '.css'
        }],
        options: {
          sourcemap: 'none',
          style: 'compressed'
        }
      }
    },
    watch: {
      files: [
        'src/code/public/js/**/*.js',
        'src/code/sass/**/*.scss',
        'src/code/views/**/*.jade'
      ],
      tasks: ['sass', 'copy']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['sass', 'copy']);

};