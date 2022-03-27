
// 加载opencv
const initFiles = require('./wechat_qrcode_files')
const createCv = require('./opencv')

// 1. 准备Module
const Module = {
  preRun: [],
  postRun: [] ,
  onRuntimeInitialized: function() {
    console.log("opencv is ready");
  },
  print: (function() {
    return function(text) {
      console.log(text);
    };
  })(),
  printErr: function(text) {
    console.error(text);
  },
  setStatus: function(text) {
    console.log(text);
  },
  totalDependencies: 0
};

Module.setStatus('Downloading...');

initFiles(Module);

createCv(Module)

module.exports = Module
