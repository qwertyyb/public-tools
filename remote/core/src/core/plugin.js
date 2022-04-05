const path = require('path')
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

const getCommands = () => {
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
  return commands;
}

const setCurPlugin = (targetPluginName) => {
  curPlugin = plugins.get(targetPluginName);
  return curPlugin
}

ws.on('message',async  (message) => {
  const messageData = MessageData.fromJSON(message);
  const { type, payload, replyId } = JSON.parse(message)
  console.log('receive Message', JSON.parse(message))

  if (type === 'getCommands') {
    return send(messageData.makeReplyMessage({ commands: getCommands() }))
  }

  if (type === 'onSearch') {
    const plugin = setCurPlugin(payload.command.id);
    if (!plugin) {
      console.warn(`插件${payload.command.id}不存在`)
    }
    const results = (await plugin?.onSearch(payload.keyword)) || [];
    return send(messageData.makeReplyMessage({ results }))
  }

  if (type === 'onResultSelected') {
    setCurPlugin(payload.command.id);
    if (!curPlugin) {
      console.warn(`插件不存在`)
    }
    const html = (await curPlugin?.onResultSelected(payload.result)) ?? null
    return send(messageData.makeReplyMessage({ html }))
  }

  if (type === 'onEnter') {
    setCurPlugin(payload.command.id);
    if (!curPlugin) {
      console.warn(`插件${payload.command.id}不存在`)
    }
    curPlugin?.onEnter(payload.command);
  }

  if (type === 'onResultTap') {
    setCurPlugin(payload.command.id);
    if (!curPlugin) {
      console.warn(`插件不存在`)
    }
    curPlugin?.onResultTap(payload.result)
  }

  if (type === 'onExit') {
    setCurPlugin(payload.command.id);
    if (!curPlugin) {
      console.warn(`插件不存在`)
    }
    let plugin = curPlugin;
    curPlugin = null;
    plugin?.onExit(payload.command)
  }

  if (type === 'event') {
    const { event, handlerName, eventData } = payload;
    if (event === 'domEvent' && typeof curPlugin?.methods?.[handlerName] === 'function') {
      curPlugin.methods[handlerName].call(curPlugin, eventData);
    }
  }

  return send(messageData.makeReplyMessage({}))
})

const createUtils = (name) => ({
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
    send(MessageData.makeEventMessage('updateResults', { results, command: plugins.get(name) }))
  }
})

const validatePluginConfig = config => {
  const { name, title, subtitle = '', description = '', icon, mode, keywords } = config;
  const required = []
  if (!name) {
    required.push('name')
  }
  if (!title) {
    required.push('title')
  }
  if (!icon) {
    required.push('icon')
  }
  if (!mode) {
    required.push('mode')
  }
  if (!keywords || !keywords.length) {
    required.push('keywords')
  }
  if (name && plugins.get(name)) {
    return { pass: false, msg: `插件${name}已存在` }
  }
  return { pass: required.length <= 0, msg: `${required.join('、')} 为必填项` };
}

const registerPlugin = (configPath) => {
  const config = require(configPath);
  const { pass, msg } = validatePluginConfig(config);
  if (!pass) {
    createUtils().toast(msg);
    return { msg };
  }
  const pluginCreator = require(path.join(configPath, '../index.js'));
  const plugin = pluginCreator(createUtils(config.name));

  const { name, title, subtitle = '', description = '', icon, mode, keywords } = config;
  plugins.set(name, { ...plugin, id: name, title, subtitle, description, icon, mode, keywords });
  console.log(`插件${name}注册成功`);
  send(MessageData.makeEventMessage('updateCommands', { commands: getCommands() }));
  return () => {
    plugins.delete(name);
    send(MessageData.makeEventMessage('updateCommands', { commands: getCommands() }));
    if (curPlugin?.name === name) {
      curPlugin = null;
    }
  }
}

module.exports = registerPlugin