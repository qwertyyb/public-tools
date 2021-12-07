const { EventEmitter } = require('ws')
const WebSocket = require('ws')

const event = new EventEmitter()
const ws = new WebSocket('ws://127.0.0.1:4040/ws')

event.on('keyword', (keyword) => {
  console.log(keyword);
})
ws.on('open', () => {
  console.log('connect websocket success')
})

ws.on('message', (message) => {
  console.log('receive message', message)
  const { type, payload } = JSON.parse(message)
  console.log(type, payload)
  if (type === 'keyword') {
    curKeyword = payload.keyword
    event.emit('keyword', payload.keyword)
  }
})

ws.on('close', (code, reason) => {
  console.log('closed', code, reason)
})

let curKeyword;
let lastEnded = Promise.resolve();
const start = (list) => {
  return new Promise(resolve => ws.send(JSON.stringify({ type: 'list', payload: { list } }), resolve))
}

module.exports = {
  updateList: async (keyword, list) => {
    // 不是正在处理的keyword, 丢弃
    if (keyword !== curKeyword) return;
    ws.send(JSON.stringify({ type: 'list', payload: { list } }))
  },
  onKeywordChange (callback) {
    event.on('keyword', callback)
  }
}