#!/usr/bin/env node
const path = require('path')
const { getStorage, addPlugins } = require('..')
const { createCommonUtils } = require('../core/utils')

const corePlugins = [
  path.join(__dirname, '../plugins/dev/package.json'),
  path.join(__dirname, '../plugins/store/package.json'),
]

const launch = () => {
  const config = getStorage({ plugins: [] })
  const configPaths = config.plugins
    .filter(({ disabled, pluginPath }) => !disabled && !pluginPath.includes('core/src/plugins'))
    .map(({ pluginPath }) => pluginPath)
  try {
    addPlugins([...corePlugins, ...configPaths])
  } catch(err) {
    createCommonUtils().toast('插件加载失败，请检查插件配置文件是否正确: ' + err.message)
    throw err;
  }
}

launch()
