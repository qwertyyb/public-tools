const { v4: uuidv4 } = require('uuid')
const ws = require('./ws')

let curPlugin = null;
const plugins = new Map();

class MessageData {
  time = Date.now();
  id = uuidv4();
  replyId = uuidv4();
  type = 'event';
  payload = {};

  constructor(data) {
    this.type = data.type;
    this.payload = data.payload;
    this.replyId = data.replyId;
    this.time = data.time;
    this.id = data.id;
  }

  static fromJSON(data) {
    return new MessageData(JSON.parse(data));
  }

  makeReplyMessage(payload = {}) {
    return new MessageData({
      id: this.replyId,
      time: Date.now(),
      replyId: uuidv4(),
      type: 'callback',
      payload
    });
  }

  static makeEventMessage(eventName, payload = {}) {
    return new MessageData({
      id: uuidv4(),
      time: Date.now(),
      replyId: uuidv4(),
      type: 'event',
      payload: {
        ...payload,
        event: eventName
      }
    });
  }
}

const send = (obj) => {
  console.log('send', JSON.stringify(obj, null, 2));
  return ws.send(JSON.stringify(obj))
}

ws.on('message',async  (message) => {
  const messageData = MessageData.fromJSON(message);
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
    return send(messageData.makeReplyMessage({ commands }))
  }

  if (type === 'onSearch') {
    const plugin = plugins.get(payload.command.id)
    if (!plugin) {
      throw new Error(`插件${payload.command.id}不存在`)
    }
    const results = await plugin.onSearch(payload.keyword)
    return send(messageData.makeReplyMessage({ results }))
  }

  if (type === 'onResultSelected') {
    if (!curPlugin) {
      throw new Error(`插件不存在`)
    }
    const html = await curPlugin.onResultSelected(payload.result)
    return send(messageData.makeReplyMessage({ html }))
  }

  if (type === 'onEnter') {
    const plugin = plugins.get(payload.command.id)
    if (!plugin) {
      throw new Error(`插件${payload.command.id}不存在`)
    }
    curPlugin = plugin;
    plugin.onEnter(payload.command);
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
  return send(messageData.makeReplyMessage({}))
})

const createUtils = () => ({
  toast(content) {
    send(MessageData.makeEventMessage('toast', { content }))
  },
  hideApp() {
    send(MessageData.makeEventMessage('hideApp'))
  },
  showApp() {
    send(MessageData.makeEventMessage('showApp'))
  },
  updateResults(results) {
    send(MessageData.makeEventMessage('updateResults', { results, command: curPlugin.command }))
  }
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