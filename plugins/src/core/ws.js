const { EventEmitter } = require('events')
const WebSocket = require('ws')

let event = new EventEmitter()

const getWs = () => {
  let ws = null
  let reconnectTimeout = null
  const createWs = () => {
    ws = new WebSocket('ws://127.0.0.1:4040/ws')
    ws.on('open', () => {
      console.log('connect websocket success')
    })

    ws.on('message', (message) => {
      event.emit('message', message)
    })

    ws.on('close', (code, reason) => {
      console.log('closed', code, reason)
      clearTimeout(reconnectTimeout)
      reconnectTimeout = setTimeout(() => createWs(), 2000)
    })

    ws.on('error', (err) => {
      console.error(err)
      clearTimeout(reconnectTimeout)
      reconnectTimeout = setTimeout(() => createWs(), 2000)
    })
    return ws
  }
  createWs()
  event.send = (...args) => ws.send(...args)
  return event
}

module.exports = getWs()