const path = require('path')
const registerPlugin = require('./core/plugin')

registerPlugin(path.join(__dirname, './plugins/dev/plugin.json'))
registerPlugin(path.join(__dirname, './plugins/store/plugin.json'))

console.log('remote plugin is running')
