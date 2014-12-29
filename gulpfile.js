// We require coffee-react here so that node knows how to transpile
// CoffeeScript along with JSX in coffee files. This mainly applies to the
// tests which are run locally as we use a different transform for browserify.
require('coffee-react').register();
require('./gulpfile.coffee');
