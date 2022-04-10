const path = require('path')
const { removePlugin, addPlugin } = require('./plugin')
const { getStorage, setStorage } = require('./storage')

const defaultConfig = {
  plugins: [
    {
      pluginPath: path.join(__dirname, '../plugins/dev/package.json'),
      disabled: false,
    },
    {
      pluginPath: path.join(__dirname, '../plugins/store/package.json'),
      disabled: false
    }
  ]
}

const installPlugin = (pluginPath) => {
  const unregister = addPlugin(pluginPath)
  if (unregister.msg) {
    return unregister
  }
  const config = getStorage()
  config.plugins = [...config.plugins, {
    pluginPath,
    disabled: false
  }]
  setStorage(config)
}

const uninstallPlugin = (name) => {
  const { pluginPath } = getPlugin(name)
  removePlugin(name)
  const config = getStorage()
  config.plugins = config.plugins.filter(({ pluginPath: p }) => p !== pluginPath)
  setStorage(config)
}

module.exports = {
  launch,
  installPlugin,
  uninstallPlugin,
}