const { addPlugin, addPlugins, removePlugin, getPlugin, getPlugins } = require('./core/plugin')
const { installPlugin, uninstallPlugin } = require('./core/index')
const { getStorage, setStorage } = require('./core/storage')

module.exports = {
  addPlugin,
  addPlugins,
  removePlugin,
  getPlugin,
  getPlugins,

  installPlugin,
  uninstallPlugin,

  getStorage,
  setStorage,
}
