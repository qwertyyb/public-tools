const path = require('path')
const registerPlugin = require('./core/plugin')

const getPath = (filePath) => path.join(__dirname, filePath)

const paths = ['mdn/plugin.json', 'qrcode/plugin.json', 'translate/plugin.json', 'store/plugin.json', 'dev/plugin.json'].map(getPath)

paths.forEach(configPath => registerPlugin(configPath))

console.log('remote plugin is running')
