#!/usr/bin/env node
const path = require('path')
const { getStorage, addPlugin } = require('..')

const corePlugins = [
  path.join(__dirname, '../plugins/dev/package.json'),
  path.join(__dirname, '../plugins/store/package.json'),
]

const launch = () => {
  const config = getStorage({ plugins: [] })
  corePlugins.forEach(pluginPath => {
    addPlugin(pluginPath)
  })
  config.plugins.forEach(({ pluginPath, disabled }) => {
    if (!disabled) {
      addPlugin(pluginPath)
    }
  })
}

launch()
