'use strict';

var gulp = require('gulp');
var runSequence = require('run-sequence');
var preprocess = require('gulp-preprocess');
var clean = require('gulp-clean');
var $ = require('gulp-load-plugins')();
var robots = require('gulp-robots');
var minifyHTML = require('gulp-htmlmin');
var jshintStylish = require('jshint-stylish');
var less = require('gulp-less');
var coffeelint = require('gulp-coffeelint');
var imagemin = require('gulp-imagemin');
var sitemap = require('gulp-sitemap');
var mainBowerFiles = require('main-bower-files');
var modernizr = require('gulp-modernizr');
var pngquant = require('imagemin-pngquant');
var browserSync = require('browser-sync').create();
var sourcemaps = require('gulp-sourcemaps');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');
var watchify = require('watchify');
var browserify = require('browserify');
var coffeeify = require('coffeeify');
var hbsfy = require('hbsfy');
var gutil = require('gulp-util');
var assign = require('lodash.assign');
var coffee = require('gulp-coffee');
var rev = require('gulp-rev');
var revReplace = require("gulp-rev-replace");
var gzip = require('gulp-gzip');
var git = require('git-rev');
var fs = require('fs');
var rimraf = require('gulp-rimraf');
var replace = require('gulp-replace');
var srizer = require('gulp-srizer');

const siteUrl = 'https://sritest.io';

var gzip_options = {
    threshold: '1kb',
    gzipOptions: {
        level: 9
    }
};

/*
 * Define paths
 */
const paths = {
      jsFiles: 'js/src/*.coffee',
      jsDirectory: 'js/',
      jsVendorFiles: 'js/vendor/*.js',
      jsVendorDirectory: 'js/vendor',
      cssFiles: 'css/*.css',
      cssDirectory: 'css/',
      cssVendorFiles: 'css/vendor/*.css',
      cssVendorDirectory: 'css/vendor',
      lessFiles: 'less/*.less',
      lessDirectory: 'less/',
      imageFiles: 'img/**/*',
      imageDirectory: 'img/',
      textFiles: '*.txt',
      htmlFiles: '*.html',
      tiles: '*.png',
      favicon: 'favicon.ico',
};

const SRC = './src/';
const DST = './dist/';

/*
 * Delete the dist directory
 */
gulp.task('clean', function() {
    return gulp.src(DST)
        .pipe(clean());
});

/*
 * Write Git commit longhash into file
 */
gulp.task('git-longhash', function () {
    var file = DST + '/build.txt';
    return git.long(function (longhash) {
      fs.writeFile(file, longhash)
    })
});

/*
 * Delete the dist directory
 */
gulp.task('gzip', function() {
    var assets = [DST + '**/*.js', DST + '**/*.css', DST + '**/*.html'];
    return gulp.src(assets)
        .pipe(gzip(gzip_options))
        .pipe(gulp.dest(DST));
});

gulp.task('revision', function() {
    var assets = [
      DST + '**/*.js',
      DST + '**/*.css',
      DST + paths.imageFiles
    ];
    return gulp.src(assets, {base: DST})
        .pipe(rimraf())
        .pipe(rev())
        .pipe(gulp.dest(DST))
        .pipe(rev.manifest({
          base: DST,
          merge: true,
          path: DST + 'rev-manifest.json'
        }))
        .pipe(gulp.dest(DST));
});

gulp.task('revreplace', ['revision'], function(){
  var manifest = gulp.src(DST + '/rev-manifest.json');
  return gulp.src(DST + paths.htmlFiles)
    .pipe(revReplace({manifest: manifest}))
    .pipe(gulp.dest(DST));
});

/*
 * Copy tiles
 */
gulp.task('copy-tiles', function() {
    return gulp.src(SRC+paths.tiles)
        .pipe(gulp.dest(DST));
});

/*
 * Copy favicon.ico
 */
gulp.task('copy-favicon', function() {
    return gulp.src(SRC+paths.favicon)
        .pipe(gulp.dest(DST));
});

/*
 * Generate robots.txt
 */
gulp.task('robots', function () {
    return gulp.src(SRC+'index.html')
        .pipe(robots({
            sitemap: siteUrl + '/sitemap.xml'
        }))
        .pipe(gulp.dest(DST));
});

/*
 * Process HTML files
 */
gulp.task('html-dist', function() {
  return gulp.src(SRC+paths.htmlFiles)
      .pipe(gulp.dest(DST));
});

/*
 * Add code snippets into HTML files from templates
 */
gulp.task('inject-code-snippets', function () {
  var options = {
    includeBase: SRC + 'templates/'
  };
  return gulp.src(DST+paths.htmlFiles)
      .pipe(preprocess(options))
      .pipe(gulp.dest(DST));
});

/*
 * Minify HTML files
 */
// We keep this separate from 'html-dist', otherwise 'generate-sri' won't work
gulp.task('minify-html', function () {
  var opts = {
      collapseWhitespace: true
  };
  return gulp.src(DST+paths.htmlFiles)
      .pipe($.removeHtmlComments())
      .pipe(minifyHTML(opts))
      .pipe(gulp.dest(DST));
});

/*
 * Optimize images
 */
gulp.task('minimize-images', function() {
    return gulp.src(SRC+paths.imageFiles)
        .pipe(imagemin({
            progressive: true,
            svgoPlugins: [{removeViewBox: false}],
            use: [pngquant()]
        }))
        .pipe(gulp.dest(DST+paths.imageDirectory));
});

/*
 * Copy vendor js files
 */
gulp.task('copy-vendor-js', function() {
    return gulp.src(SRC+paths.jsVendorFiles)
        .pipe(gulp.dest(DST+paths.jsVendorDirectory));
});

/*
 * Copy vendor CSS files
 */
gulp.task('copy-vendor-css', function() {
    return gulp.src(SRC+paths.cssVendorFiles)
        .pipe(gulp.dest(DST+paths.cssVendorDirectory));
});

/*
 * Copy fonts for Semantic UI icons
 */
gulp.task('copy-semantic-ui-icons', function() {
    return gulp.src(SRC+paths.cssVendorDirectory+'/themes/default/assets/fonts/*')
        .pipe(gulp.dest(DST+paths.cssVendorDirectory+'/themes/default/assets/fonts/'));
});

gulp.task('install-bower-packages-js', function() {
    return gulp.src(mainBowerFiles({
          filter: /\..*js$/i,
          overrides: {
            "jquery": {
              "main": "**/jquery.min.js"
            },
            "highlightjs": {
              "main": "**/highlight.pack.min.js"
            }
          }
        }))
        .pipe(gulp.dest(DST+paths.jsVendorDirectory));
});

gulp.task('install-bower-packages-css', function() {
  return gulp.src(mainBowerFiles({
        filter: /\..*css$/i,
          overrides: {
            "highlightjs": {
              "main": "**/androidstudio.css"
            }
          }
        }))
        .pipe(gulp.dest(DST+paths.cssVendorDirectory));
});

/*
 * Compile LESS to CSS
 */
gulp.task('less-dist', function () {
    return gulp.src(SRC+paths.lessDirectory+'app.less')
        .pipe(less())
        .pipe($.autoprefixer({
            browsers: ['last 2 versions'],
            cascade: false
        }))
        .pipe($.stripComments())
        .pipe($.minifyCss({compatibility: 'ie8'}))
        .pipe(gulp.dest(DST+paths.cssDirectory))
        .pipe(browserSync.stream());
});

/*
 * Lint your JavaScript
 */
gulp.task('coffee-lint', function () {
    return gulp.src(SRC+paths.jsFiles)
        .pipe(coffeelint())
        .pipe(coffeelint.reporter());
});

/*
 * Lint your CSS
 */
gulp.task('css-lint', function () {
    return gulp.src(SRC+paths.cssFiles)
        .pipe($.csslint())
        .pipe($.csslint.reporter());
});

/*
 * Beautify your CSS
 */
gulp.task('beautify-css', function () {
    return gulp.src(SRC+paths.cssFiles)
        .pipe($.cssbeautify())
        .pipe(gulp.dest(SRC+paths.cssDirectory));
});

/*
 * Strip, prefix, minify and concatenate your CSS during a deployment
 */
gulp.task('css-dist', function () {
    return gulp.src(SRC+paths.cssFiles)
        .pipe($.plumber())
        .pipe($.autoprefixer({
            browsers: ['last 2 versions'],
            cascade: false
        }))
        .pipe($.stripComments())
        .pipe($.concat('main.css'), {newLine: ''})
        .pipe($.minifyCss({compatibility: 'ie8'}))
        .pipe(gulp.dest(DST+paths.cssDirectory))
});

/*
 * Watchify CoffeeScript files into main.js
 */
gulp.task('coffee-watch', bundle);

var customOpts = {
  entries: [
      SRC+paths.jsDirectory+'/main.coffee'
  ],
  debug: true,
  transform: [coffeeify, [hbsfy, {extensions: ['hbs']}]]
};
var opts = assign({}, watchify.args, customOpts);
var b = watchify(browserify(opts));

b.on('update', bundle); // on any dep update, runs the bundler
b.on('log', gutil.log); // output build logs to terminal

function bundle() {
  gutil.log('Compiling scripts ...');
  return b.bundle()
    .on('error', gutil.log.bind(gutil, 'Browserify Error'))
    .pipe(source('main.js'))
    .pipe(buffer())
    .pipe(sourcemaps.init({loadMaps: true}))
        .pipe($.uglify())
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest(DST+paths.jsDirectory))
    .pipe(browserSync.stream());
}

/*
 * Browserify CoffeeScript files into main.js
 */
gulp.task('browserify-dist', function () {
  var opts = {
    entries: [
        SRC+paths.jsDirectory+'/main.coffee'
    ],
    debug: true,
    transform: [coffeeify, [hbsfy, {extensions: ['hbs']}]],
    cache: {},
    packageCache: {}
  };

  var b = browserify(opts);
  return b.bundle()
    .on('error', gutil.log.bind(gutil, 'Browserify Error'))
    .pipe(source('main.js'))
    .pipe(buffer())
    .pipe(sourcemaps.init({loadMaps: true}))
        .pipe($.uglify())
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest(DST+paths.jsDirectory));
});

/*
 * Compile your Coffeescript
 */
gulp.task('coffee-dist', function () {
    return gulp.src(SRC+paths.jsFiles)
        .pipe(coffeelint())
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(coffeelint.reporter())
        .pipe(gulp.dest(DST+paths.jsDirectory));
});

/*
 * Strip, minify and concatenate your JavaScript during a deployment
 */
gulp.task('generate-modernizr', function () {
    return gulp.src(DST+paths.jsDirectory+'*.js')
        .pipe(modernizr())
        .pipe($.uglify())
        .pipe(gulp.dest(DST+paths.jsDirectory));
});

/*
 * Generate sitemap file
 */
gulp.task('sitemap', function () {
    var files = [SRC+'**/*.html', '!'+SRC+'50x.html'];
    gulp.src(files)
        .pipe(sitemap({
            siteUrl: siteUrl
        }))
        .pipe(replace('.html', ''))
        .pipe(gulp.dest(DST));
});

/*
 * Generate SRI hashes for all local assets
 */
gulp.task('generate-sri', function() {
    var files = [
      DST + paths.htmlFiles,
    ];
    var options = {
      fileExt: ['css', 'js']
    }
    return gulp.src(files)
        .pipe(srizer())
        .pipe(gulp.dest(DST));
});

/*
 * Watchers
 */
gulp.task('watch', function () {
    gulp.watch(SRC+paths.jsFiles, ['coffee-lint']);
    gulp.watch(SRC+paths.cssFiles, ['css-lint']);
    gulp.watch(SRC+paths.lessDirectory+'app.less', ['less-dist']);
});

/*
 * Build project for production
 */
gulp.task('build', function(callback) {
  runSequence('clean',
              'robots',
              ['copy-tiles', 'copy-favicon'],
              ['coffee-lint'],
              ['css-dist', 'browserify-dist', 'coffee-dist', 'html-dist', 'less-dist'],
              ['copy-vendor-js', 'copy-vendor-css', 'copy-semantic-ui-icons'],
              ['install-bower-packages-js', 'install-bower-packages-css'],
              'generate-modernizr',
              'minimize-images',
              'sitemap',
              'revreplace',
              'generate-sri',
              'inject-code-snippets',
              'minify-html',
              'gzip',
              'git-longhash',
              callback
  )
});

/*
 * Build project for developing
 */
gulp.task('default', function(callback) {
  runSequence('clean',
              ['copy-tiles', 'copy-favicon'],
              ['coffee-lint'],
              ['css-dist', 'browserify-dist', 'coffee-dist', 'html-dist', 'less-dist'],
              ['copy-vendor-js', 'copy-vendor-css', 'copy-semantic-ui-icons'],
              ['install-bower-packages-js', 'install-bower-packages-css'],
              'generate-modernizr',
              'inject-code-snippets',
              callback
  )
});

gulp.task('beautify', ['beautify-css']);

/*
 * Serve files trough BrowserSync
 */
gulp.task('html-watch', ['html-dist'], browserSync.reload);
gulp.task('js-watch', ['coffee-dist'], browserSync.reload);
gulp.task('less-watch', ['less-dist']);

gulp.task('serve', ['coffee-watch'], function () {
    browserSync.init({
        server: {
          baseDir: DST
        }
    });
    gulp.watch(SRC+paths.htmlFiles, ['html-watch']);
    gulp.watch(SRC+paths.lessFiles, ['less-watch']);
    gulp.watch(SRC+paths.jsFiles, ['js-watch']);
});
