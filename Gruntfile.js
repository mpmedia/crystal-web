module.exports = function(grunt) {

    grunt.initConfig({
        "name": "json",
        "hash": {},
        "data": {
            "root": {
                "loadNpmTasks": [
                    "grunt-contrib-sass",
                    "grunt-contrib-watch"
                ],
                "registerTask": {
                    "default": [
                        "sass"
                    ]
                },
                "config": {
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
                        "files": [
                            "src/public/js/**/*.js",
                            "src/sass/**/*.scss",
                            "src/views/**/*.jade"
                        ],
                        "tasks": [
                            "sass",
                            "copy"
                        ]
                    }
                }
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('default', ['sass']);

};