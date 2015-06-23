module.exports = function(grunt) {

    grunt.initConfig({
        "pkg": "package.json",
        "sass": {
            "dist": {
                "files": [{
                    "expand": true,
                    "cwd": "src/sass",
                    "src": [
                        "**/*.scss"
                    ],
                    "dest": "src/public/css",
                    "ext": ".css"
                }],
                "options": {
                    "sourcemap": "none",
                    "style": "compressed"
                }
            }
        },
        "watch": {
            "files": "src/sass/**/*.scss",
            "tasks": [
                "sass"
            ]
        }
    });

    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('default', ['sass']);

};