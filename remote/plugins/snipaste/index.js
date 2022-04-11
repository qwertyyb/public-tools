const fs = require('fs')
const { exec } = require('child_process')

const getCliPath = () => {
  const cliPath = '/Applications/Snipaste.app/Contents/MacOS/Snipaste'
  if (fs.existsSync(cliPath)) {
    return cliPath
  }
  return null
}

const snipaste = (cliPath) => {
  console.log('start')
  return exec(`${cliPath} snip`)
}

const plugin = utils => ({
  onEnter: () => {
    console.log('onEnter')
    const cliPath = getCliPath()
    if (!cliPath) {
      return utils.toast('Snipaste未安装')
    }
    snipaste(cliPath)
    return utils.hideApp();
  },
  onExit: () => {},
  onSearch: () => {
    return []
  },
  onResultSelected: () => {},
  onResultTap: () => {},
})

module.exports = plugin