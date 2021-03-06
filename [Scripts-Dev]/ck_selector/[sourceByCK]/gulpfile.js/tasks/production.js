var gulp = require("gulp");
var runSequence = require("run-sequence");

gulp.task("production", function(cb) {
  global.PRODUCTION = true;
  runSequence(
    "clean",
    "fonts",
    "assets",
    "scripts",
    "styles",
    "html",
    "viewLinker",
    function cb() {
      process.exit(0);
    }
  );
});
