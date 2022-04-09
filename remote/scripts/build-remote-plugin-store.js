const path = require('path')
const fs = require('fs')
const { publishPlugins } = require('./publish-plugins')

const pluginListDir = path.join(__dirname, '../plugins')
const storeJsonFile = path.join(__dirname, '../gh-pages/store.json')

const getPluginConfigList = () => {
  return fs.readdirSync(pluginListDir)
    .map(pluginDirName => {
      const configPath = path.join(pluginListDir, pluginDirName, './package.json')
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
    plugins: configList
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

const main = async () => {
  const results = await publishPlugins()
  console.log(results);
  generateJsonFile()
  console.log('generate success')
}

main()



