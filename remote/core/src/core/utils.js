const fs = require('fs')
const MessageData = require('./message-data')
const { invoke } = require('./ws')

const createCommonUtils = () => ({
  toast(content) {
    return invoke(MessageData.makeEventMessage('toast', { content }))
  },
  hideApp() {
    return invoke(MessageData.makeEventMessage('hideApp'))
  },
  showApp() {
    return invoke(MessageData.makeEventMessage('showApp'))
  },
})

const createPluginUtils = (name, plugins) => ({
  updateResults(results) {
    name = name.startsWith('@public-tools/') ? name : `@public-tools/plugin-${name}`
    return invoke(MessageData.makeEventMessage('updateResults', { results, command: plugins.get(name) }))
  },
  updatePreview(html) {
    name = name.startsWith('@public-tools/') ? name : `@public-tools/plugin-${name}`
    return invoke(MessageData.makeEventMessage('updatePreview', { html, command: plugins.get(name) }))
  }
})

const createStorage = (() => {
  const filePath = process.env.HOME + '/Library/Application Support/cn.qwertyyb.public/storage.json';
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, '{}', 'utf-8')
  }
  const value = JSON.parse(fs.readFileSync(filePath, 'utf-8'))
  const persistToFile = () => {
    fs.writeFileSync(filePath, JSON.stringify(value), 'utf-8')
  }
  return (name) => {
    name = name.startsWith('@public-tools/') ? name : `@public-tools/plugin-${name}`
    return {
      set(key, val) {
        if (!value[name]) {
          value[name] = {}
        }
        value[name][key] = val
        persistToFile()
      },
      get(key) {
        return value[name]?.[key]
      }
    }
  }
})()

const createUtils = (name, plugins) => ({
  ...createCommonUtils(),
  ...createPluginUtils(name, plugins),
  storage: createStorage(name)
})


module.exports = {
  createUtils,
  createPluginUtils,
  createCommonUtils,
}
