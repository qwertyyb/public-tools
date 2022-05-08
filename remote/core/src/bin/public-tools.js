#!/usr/bin/env node
const path = require('path')
const fs = require('fs')
const { addPlugins } = require('..')
const { createCommonUtils } = require('../core/utils')

const corePlugins = [
  path.join(__dirname, '../plugins/dev/package.json'),
  path.join(__dirname, '../plugins/store/package.json'),
]

const getDevPlugins = () => {
  const pluginsDir = path.join(__dirname, '../../../plugins')
  const pluginConfigs = fs.readdirSync(pluginsDir).filter(item => !item.startsWith('.')).map(dir => path.join(pluginsDir, dir, 'package.json')).filter(configPath => fs.existsSync(configPath))
  return pluginConfigs
}

const getProdPlugins = () => {
  const cwd = path.join(process.env.HOME, 'Library/Application Support/cn.qwertyyb.public/plugins')
  const pluginsDir = path.join(cwd, 'node_modules/@public-tools/')
  console.log(fs.readdirSync(pluginsDir), pluginsDir)
  const pluginConfigs = fs.readdirSync(pluginsDir)
    .filter(item => item.startsWith('plugin-'))
    .map(dir => path.join(pluginsDir, dir, 'package.json'))
    .filter(configPath => fs.existsSync(configPath))
  return pluginConfigs
}

const getExternalPlugins = () => {
  if (process.env.NODE_ENV === 'development') {
    return getDevPlugins()
  }
  return getProdPlugins()
}

const launch = () => {
  const configPaths = getExternalPlugins();
  console.log('external plugins:', configPaths);
  try {
    addPlugins([...corePlugins, ...configPaths])
  } catch(err) {
    createCommonUtils().toast('插件加载失败，请检查插件配置文件是否正确: ' + err.message)
    throw err;
  }
}

launch()
