const ws = require('./ws')

let curPlugin = null;
const plugins = new Map();

const send = (type, replyId, payload) => {
  console.log('send', type, replyId, payload)
  return ws.send(JSON.stringify({ type, id: replyId, payload }))
}

ws.on('message',async  (message) => {
  const { type, payload, replyId } = JSON.parse(message)
  console.log('receive Message', JSON.parse(message))

  if (type === 'getCommands') {
    const commands = Array.from(plugins.values()).map(plugin => {
      const { title, subtitle, description, id, icon, mode, keywords } = plugin;
      return {
        id,
        title,
        subtitle,
        description,
        icon,
        mode,
        keywords
      }
    })
    send('callback', replyId, { commands })
  }

  if (type === 'onEnter') {
    const plugin = plugins.get(payload.command.id)
    if (!plugin) {
      throw new Error(`插件${payload.command.id}不存在`)
    }
    curPlugin = plugin;
    plugin.onEnter(payload.command);
  }

  if (type === 'onSearch') {
    const plugin = plugins.get(payload.command.id)
    if (!plugin) {
      throw new Error(`插件${payload.command.id}不存在`)
    }
    const results = await plugin.onSearch(payload.keyword)
    send('callback', replyId, { results })
  }

  if (type === 'onResultSelected') {
    if (!curPlugin) {
      throw new Error(`插件不存在`)
    }
    const html = await curPlugin.onResultSelected(payload.result)
    send('callback', replyId, { html })
  }

  if (type === 'onResultTap') {
    if (!curPlugin) {
      throw new Error(`插件不存在`)
    }
    curPlugin.onResultTap(payload.result)
  }

  if (type === 'onExit') {
    if (!curPlugin) {
      throw new Error(`插件不存在`)
    }
    let plugin = curPlugin;
    curPlugin = null;
    plugin.onExit(payload.command)
  }
})

const createUtils = () => ({
  toast(content) {
    send('toast', '', { content })
  },
  hideApp() {
    send('hideApp', '', {})
  },
  showApp() {
    send('showApp', '', {})
  },
})


const createPlugin = (pluginCreator) => {
  const plugin = pluginCreator(createUtils())
  const { id } = plugin;
  if (plugins.get(id)) {
    throw new Error('当前插件已存在')
  }
  plugins.set(id, plugin)
  return plugin
}

module.exports = createPlugin;