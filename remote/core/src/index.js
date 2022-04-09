const path = require('path')
const registerPlugin = require('./core/plugin')

registerPlugin(path.join(__dirname, './plugins/dev/package.json'))
registerPlugin(path.join(__dirname, './plugins/store/package.json'))

console.log('remote plugin is running')
