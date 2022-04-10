const { EventEmitter } = require('events')
const WebSocket = require('ws')

let event = new EventEmitter()

const getWs = () => {
  let ws = null
  let wsReadyCallback;
  let wsReady = new Promise(resolve => { wsReadyCallback = resolve })
  const createWs = () => {
    ws = new WebSocket('ws://127.0.0.1:4040/ws')
    ws.on('open', () => {
      console.log('connect websocket success')
      wsReadyCallback && wsReadyCallback()
    })

    ws.on('message', (message) => {
      event.emit('message', message)
    })

    ws.on('close', (code, reason) => {
      console.log('closed', code, reason)
    })

    ws.on('error', (err) => {
      console.error(err)
    })
    return ws
  }
  createWs()
  event.send = async (...args) => {
    await wsReady
    return ws.send(...args)
  }
  return event
}

module.exports = getWs()