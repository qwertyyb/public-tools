const path = require('path')
const fs = require('fs')


const pluginDirList = ['src/mdn', 'src/qrcode', 'src/translate']

const getPluginConfig = (pluginDir) => {
  const mdPath = path.join(__dirname, pluginDir, './README.md')
  const pkgPath = path.join(__dirname, pluginDir, './package.json')

  const pkg = require(pkgPath)
  pkg.intro = fs.readFileSync(mdPath, 'utf-8')

  return pkg
}

const getPluginsConfig = () => {
  return pluginDirList.map(getPluginConfig)
}

const generateJsonFile = () => {
  const pluginList = getPluginsConfig()

  const config = {
    updateTime: Date.now(),
    pluginList,
  }

  fs.writeFileSync(path.join(__dirname, './plugins.json'), JSON.stringify(config), 'utf-8')
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



