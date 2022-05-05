const convert = {
  ts: num => {
    try {
      const date = new Date()
      date.setTime(+num)
      return date.toLocaleString('zh-CN', { hour12: false });
    } catch(err) {
      return 'error'
    }
  },
  encode: str => encodeURIComponent(str),
  decode: str => decodeURIComponent(str),
}

const plugin = utils => ({
  onEnter: () => {},
  onExit: () => {},

  onSearch: (keyword) => {
    const [_command, ...args] = keyword.split(' ')
    const command = _command.toLocaleString()
    const str = args.join(' ')
    if (command === 'ts') {
      const val = convert.ts(str)
      return [{
        title: val,
        subtitle: str,
        icon: 'https://img.icons8.com/fluency/96/000000/calendar-13.png',
        description: '',
        id: val,
      }]
    }
    if (command === 'encode' || command === 'decode') {
      const val = convert[command](str)
      return [{
        title: val,
        subtitle: str,
        icon: 'https://img.icons8.com/fluency/96/000000/link.png',
        description: '',
        id: val,
      }]
    }
    return []
  },
  onResultSelected: (result) => {
    return null
  },
  onResultTap: (result) => {
    return null
  }
})

module.exports = plugin
