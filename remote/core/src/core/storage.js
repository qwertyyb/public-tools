const fs = require('fs');
const path = require('path')
const registerPlugin = require('./plugin')

const pluginConfigPath = process.env.HOME + '/Library/Application Support/cn.qwertyyb.public/plugins.json';

const initStorage = (defaultValue) => {
  fs.writeFileSync(pluginConfigPath, JSON.stringify(defaultValue))
}

const getStorage = (defaultValue) => {
  if (!fs.existsSync(pluginConfigPath)) {
    initStorage(defaultValue)
  }
  try {
    const configPathList = JSON.parse(fs.readFileSync(pluginConfigPath, 'utf-8'))
    return configPathList
  } catch(err) {
    fs.unlinkSync(pluginConfigPath)
    initStorage()
    return defaultValue
  }
}

const setStorage = (config) => {
  fs.writeFileSync(pluginConfigPath, JSON.stringify(config))
}

module.exports = {
  getStorage,
  setStorage,
}