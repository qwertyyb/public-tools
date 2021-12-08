const { EventEmitter } = require('ws')
const WebSocket = require('ws')

const event = new EventEmitter()
let curKeyword;
const plugins = new Map();
const ws = new WebSocket('ws://127.0.0.1:4040/ws')

event.on('tap', ({ item }) => {
  const { id: idWithName, ...restAttrs } = item;
  const [name, ...rest] = idWithName.split('-')
  const id = rest.join('-')
  const plugin = plugins.get(name)
  if (!plugin) {
    throw new Error(`插件${name}不存在`)
  }
  event.emit(`${name}-onTap`, { ...restAttrs, id })
})

ws.on('open', () => {
  console.log('connect websocket success')
})

ws.on('message', (message) => {
  const { type, payload } = JSON.parse(message)
  console.log(type, payload)
  if (type === 'keyword') {
    curKeyword = payload.keyword
    event.emit('keyword', payload.keyword)
  } else if (type === 'tap') {
    event.emit('tap', payload)
  }
})

ws.on('close', (code, reason) => {
  console.log('closed', code, reason)
})

const createPlugin = (name) => {
  if (plugins.get(name)) {
    throw new Error('当前插件已存在')
  }
  const plugin = {
    updateList: async (keyword, list) => {
      // 不是正在处理的keyword, 丢弃
      if (keyword !== curKeyword) return;
      const handledList = list.map(item => {
        return {
          ...item,
          id: `${name}-${item.id}`
        }
      })
      ws.send(JSON.stringify({ type: 'list', payload: { list: handledList } }))
    },
    // @todo 添加是否防抖选项
    onKeywordChange (callback) {
      event.on('keyword', callback)
    },
    onTap(cb) {
      event.on(`${name}-onTap`, cb)
    }
  }
  plugins.set(name, plugin)
  return plugin
}

module.exports = createPlugin;