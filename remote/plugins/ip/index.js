const { exec } = require('child_process')
const os = require('os')
const { promisify } = require('util')
const clipboard = require('simple-mac-clipboard')

const getLocalIpInfo = () => {
  const ifaces = os.networkInterfaces()
  const iface = Object.values(ifaces).flat().find(iface => 'IPv4' === iface.family && !iface.internal)
  return iface ? {
    ip: iface.address,
  } : null
}


const getIpInfo = async () => {
  const resp = await promisify(exec)('curl cip.cc')
  const infoArr = resp.stdout.split('\n').filter(i => i.trim())
  const info = {
    ip: infoArr[0].split(':')[1],
    addr: infoArr[1].split(':')[1],
  }
  return info
}

const plugin = utils => ({
  onEnter: () => {},
  onExit: () => {},

  async onSearch(keyword) {
    const localIpInfo = getLocalIpInfo()
    let remoteIpInfo = null;
    try {
      remoteIpInfo = await getIpInfo()
    } catch(err) {
      console.log('getIpInfo err', err)
    }
    const results = []
    if (localIpInfo) {
      results.push({
        title: localIpInfo.ip,
        subtitle: '本机IP',
        description: '',
        icon: 'https://img.icons8.com/color-glass/96/000000/ip-address.png',
        id: localIpInfo.ip,
      })
    }
    if (remoteIpInfo) {
      results.push({
        title: remoteIpInfo.ip,
        subtitle: remoteIpInfo.addr,
        description: '',
        icon: 'https://img.icons8.com/color/96/000000/ip-address.png',
        id: remoteIpInfo.ip,
      })
    }
    return results;
  },
  onResultSelected(result) {
    return null
  },
  onResultTap(result) {
    clipboard.writeText(clipboard.FORMAT_PLAIN_TEXT, result.title)
    utils.toast('已复制到剪贴板')
  }
})

module.exports = plugin
