const path = require('path')
const npmPublish = require("@jsdevtools/npm-publish");

const corePkgPath = path.join(__dirname, '../core/package.json');

const publishCore = async () => {
  return npmPublish({
    package: corePkgPath,
    token: process.env['NPM_TOKEN'],
    access: 'public',
  })
}

publishCore()