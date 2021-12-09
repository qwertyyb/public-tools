const { EventEmitter } = require('ws')
const WebSocket = require('ws')

const event = new EventEmitter()
let curKeyword;
let curPlugin = null;
const plugins = new Map();
const ws = new WebSocket('ws://127.0.0.1:4040/ws')

const send = (type, payload) => ws.send(JSON.stringify({ type, payload }))

event.on('tap', ({ item }) => {
  if (curPlugin) {
    const { id: idWithName, ...restAttrs } = item;
    const [name, ...rest] = idWithName.split('-')
    const id = rest.join('-')
    const plugin = plugins.get(name)
    if (!plugin) {
      throw new Error(`插件${name}不存在`)
    }
    return event.emit(`${name}-onTap`, { ...restAttrs, id })
  }
  const plugin = plugins.get(item.id)
  if (!plugin) {
    throw new Error(`插件${item.id}不存在`)
  }
  curPlugin = plugin;
  send('enter', { item: item })
})

event.on('keyword', ({ keyword }) => {
  if (curPlugin) {
    return event.emit(`${curPlugin.name}-keyword`, { keyword })
  }
  const list = Array.from(plugins.keys()).filter(name => name.includes(keyword)).map(name => {
    const plugin = plugins.get(name)
    return {
      id: name,
      ...plugin.config
    }
  })
  send('list', { list })
})

event.on('exit', () => {
  curPlugin = null
})

ws.on('open', () => {
  console.log('connect websocket success')
})

ws.on('message', (message) => {
  const { type, payload } = JSON.parse(message)
  console.log(type, payload)
  if (type === 'keyword') {
    curKeyword = payload.keyword
    event.emit('keyword', payload)
  } else if (type === 'tap') {
    event.emit('tap', payload)
  } else if (type === 'exit') {
    event.emit('exit', payload)
  }
})

ws.on('close', (code, reason) => {
  console.log('closed', code, reason)
})

const createPlugin = (name, { title, subtitle, icon }) => {
  if (plugins.get(name)) {
    throw new Error('当前插件已存在')
  }
  const plugin = {
    name,
    config: { title, subtitle, icon },
    updateList: async (keyword, list) => {
      // 不是正在处理的keyword, 丢弃
      if (keyword !== curKeyword) return;
      const handledList = list.map(item => {
        return {
          ...item,
          id: `${name}-${item.id}`
        }
      })
      console.log(handledList)
      send('list', { list: handledList })
    },
    // @todo 添加是否防抖选项
    onKeywordChange (callback) {
      event.on(`${name}-keyword`, callback)
    },
    onTap(cb) {
      event.on(`${name}-onTap`, cb)
    }
  }
  plugins.set(name, plugin)
  return plugin
}

module.exports = createPlugin;