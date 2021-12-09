
// 加载opencv

// 1. 准备Module
global.Module = {
  preRun: [],
  postRun: [] ,
  onRuntimeInitialized: function() {
    console.log("Emscripten runtime is ready, launching QUnit tests...");
    if (global.cv instanceof Promise) {
      global.cv.then((target) => {
         global.cv = target;
      })
    }
  },
  print: (function() {
    return function(text) {
      // console.log(text);
    };
  })(),
  printErr: function(text) {
    // console.error(text);
  },
  setStatus: function(text) {
    console.log(text);
  },
  totalDependencies: 0
};

Module.setStatus('Downloading...');

require('./wechat_qrcode_files.js')

require('./opencv')

module.exports = Module
