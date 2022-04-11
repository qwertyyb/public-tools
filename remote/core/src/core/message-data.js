const { v4: uuidv4 } = require('uuid')

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

module.exports = MessageData