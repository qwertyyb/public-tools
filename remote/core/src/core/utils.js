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

const createUtils = (name, plugins) => ({
  ...createCommonUtils(),
  ...createPluginUtils(name, plugins)
})


module.exports = {
  createUtils,
  createPluginUtils,
  createCommonUtils,
}
