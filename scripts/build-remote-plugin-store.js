const path = require('path')
const fs = require('fs')

const pluginListDir = path.join(__dirname, '../remote/plugins')
const storeJsonFile = path.join(__dirname, '../gh-pages/store.json')

const getPluginConfigList = () => {
  return fs.readdirSync(pluginListDir)
    .map(pluginDirName => {
      console.log(pluginDirName);
      const configPath = path.join(pluginListDir, pluginDirName, './plugin.json')
      return fs.existsSync(configPath) ? configPath : null
    })
    .filter(i => i)
    .map(configPath => {
      return require(configPath)
    })
}

const generateJsonFile = () => {
  const configList = getPluginConfigList()

  const config = {
    updateTime: Date.now(),
    plugins: configList,
  }
  if (!fs.existsSync(path.dirname(storeJsonFile))) {
    fs.mkdirSync(path.dirname(storeJsonFile))
  }
  fs.writeFileSync(storeJsonFile, JSON.stringify(config), 'utf-8')
}

process.on('uncaughtException', err => {
  console.error(err)
  process.exit(-1)
})
process.on('unhandledRejection', err => {
  console.error(err)
  process.exit(-1)
})

const main = () => {
  generateJsonFile()
  console.log('generate success')
}

main()



