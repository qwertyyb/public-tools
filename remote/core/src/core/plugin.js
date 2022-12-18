const fs = require('fs');
const path = require('path')
const pinyin = require('@napi-rs/pinyin')
const ws = require('./ws')
const MessageData = require('./message-data')
const { createUtils } = require('./utils');

const invoke = ws.invoke

let curPlugin = null;
const plugins = new Map();

const setCurPlugin = (targetPluginName) => {
  curPlugin = plugins.get(targetPluginName);
  return curPlugin
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

ws.on('message',async  (message) => {
  const messageData = MessageData.fromJSON(message);
  const { type, payload } = JSON.parse(message)
  console.log('receive Message', JSON.parse(message))

  if (type === 'getCommands') {
    return invoke(messageData.makeReplyMessage({ commands: getCommands() }))
  }

  if (type === 'onSearch') {
    const plugin = setCurPlugin(payload.command.id);
    if (!plugin) {
      console.warn(`插件${payload.command.id}不存在`)
    }
    const results = (await plugin?.onSearch(payload.keyword)) || [];
    return invoke(messageData.makeReplyMessage({ results }))
  }

  if (type === 'onResultSelected') {
    setCurPlugin(payload.command.id);
    if (!curPlugin) {
      console.warn(`插件不存在`)
    }
    const html = (await curPlugin?.onResultSelected(payload.result)) ?? null
    return invoke(messageData.makeReplyMessage({ html }))
  }

  if (type === 'onEnter') {
    console.log('onEnter', payload.command)
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

  return invoke(messageData.makeReplyMessage({}))
})

const validatePluginConfig = config => {
  const { name, title, icon, mode, keywords } = config;
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
  // if (name && plugins.get(name)) {
  //   return { pass: false, msg: `插件${name}已存在` }
  // }
  return { pass: required.length <= 0, msg: `${required.join('、')} 为必填项` };
}

const notify = () => {
  invoke(MessageData.makeEventMessage('updateCommands', { commands: getCommands() }));
}

const getKeywords = (title, keywords) => {
  const pinyinArr = pinyin.pinyin(title);
  const pyStr = pinyinArr.map(i => i[0]).join('');
  return [...new Set([...keywords, pyStr, pinyinArr.join('')])];
}

const baseAddPlugin = (configPath) => {
  if (!fs.existsSync(configPath)) {
    throw new Error(`文件 ${configPath} 不存在`)
  }
  const config = require(configPath);
  const { pass, msg } = validatePluginConfig(config);
  if (!pass) {
    throw new Error(msg);
  }
  const pluginCreator = require(path.dirname(configPath));
  const plugin = pluginCreator(createUtils(config.name, plugins));

  const { name, title, subtitle = '', description = '', icon, mode, keywords } = config;
  let id = name.startsWith('@public-tools/') ? name : `@public-tools/plugin-${name}`;
  plugins.set(id, { ...plugin, pluginPath: configPath, id, title, subtitle, description, icon, mode, keywords: getKeywords(title, keywords), version: config.version });
  console.log(`插件${id}注册成功`);
  return plugins.get(id)
}

const addPlugin = configPath => {
  baseAddPlugin(configPath);
  notify();
}

const addPlugins = (configPaths) => {
  configPaths.forEach(configPath => {
    baseAddPlugin(configPath);
  })
  notify();
}

const reloadPlugin = (configPath) => {
  const dirName = path.dirname(configPath);
  Object.keys(require.cache).forEach(modulePath => {
    if (modulePath.startsWith(dirName)) {
      delete require.cache[modulePath];
    }
  })
  addPlugin(configPath);
}

const removePlugin = (name) => {
  if (!plugins.has(name)) return;
  plugins.delete(name);
  invoke(MessageData.makeEventMessage('updateCommands', { commands: getCommands() }));
  if (curPlugin?.name === name) {
    curPlugin = null;
  }
}

module.exports = {
  addPlugin,
  addPlugins,
  reloadPlugin,
  removePlugin,
  getPlugins: () => Array.from(plugins.values()),
  getPlugin: name => plugins.get(name),
}