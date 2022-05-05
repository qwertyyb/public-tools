const MessageData = require('./message-data')
const { invoke } = require('./ws')

const createCommonUtils = () => ({
  toast(content) {
    invoke(MessageData.makeEventMessage('toast', { content }))
  },
  hideApp() {
    invoke(MessageData.makeEventMessage('hideApp'))
  },
  showApp() {
    invoke(MessageData.makeEventMessage('showApp'))
  },
})

const createPluginUtils = (name, plugins) => ({
  updateResults(results) {
    invoke(MessageData.makeEventMessage('updateResults', { results, command: plugins.get(name) }))
  },
  updatePreview(html) {
    invoke(MessageData.makeEventMessage('updatePreview', { html, command: plugins.get(name) }))
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
