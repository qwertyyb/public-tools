const webpush = require('web-push')

const createPayload = (title) => {
  return JSON.stringify({
    "notification_config": {
      "title": title,
      "actions": [
         {"title": "复制", "action": "copy", "args": [title]},
      ]
     }
  })
}

const options = {
  vapidDetails: {
    subject: 'https://www.qwertyyb.com',
    publicKey: 'BBaQuJBSl1ImfSnxy5XujDhJzio3rVXAwwZHsAH9ZvJi8NNsehLifAbdzasRpbyP635md8akkidIxCu7UkBx3Mo',
    privateKey: 'hov3WUdUsfNwLvF1xx-FH_NekcjXHN8g0Vg9hYS4mN4'
  },
}

const plugin = utils => ({
  onEnter: () => {},

  onSearch: async (keyword) => {
    const subscriptions = utils.storage.get('subscriptions') || []
    const payload = createPayload(keyword)
    const results = subscriptions.map(item => {
      return {
        id: item.label,
        title: `推送到: ${item.label}`,
        subtitle: keyword,
        icon: 'https://s1.ax1x.com/2023/04/01/ppWkp0e.png',
        description: item.label,
        payload,
        subscription: item.subscription
      }
    })
    const [ action, label, ...subscriptionArr ] = keyword.split(' ')
    const subscription = subscriptionArr.join(' ')
    if (action === 'Add' && label?.trim() && subscription?.trim()) {
      results.push({
        id: 'Add',
        title: '添加推送: ' + label.trim(),
        subtitle: subscription.trim(),
        icon: 'https://s1.ax1x.com/2023/04/01/ppWkp0e.png',
        description: keyword,
        label: label.trim(),
        subscription: subscription.trim()
      })
    }
    return results
  },

  onResultSelected: async (result) => {
    return null
  },

  onResultTap: async (result) => {
    if (result.id === 'Add') {
      const subscriptions = utils.storage.get('subscriptions') || []
      subscriptions.push({
        label: result.label,
        subscription: JSON.parse(result.subscription)
      })
      utils.storage.set('subscriptions', subscriptions)
      utils.toast('已添加')
      return
    }
    webpush.sendNotification(
      result.subscription,
      result.payload,
      options
    ).then(res => {
      utils.toast('已发送到' + result.description)
    })
  },

  onExit: () => {}
})

module.exports = plugin
