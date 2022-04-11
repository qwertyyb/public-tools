#!/usr/bin/env node
const path = require('path')
const { getStorage, addPlugin } = require('..')

const defaultConfig = {
  plugins: [
    {
      pluginPath: path.join(__dirname, '../plugins/dev/package.json'),
      disabled: false,
    },
    {
      pluginPath: path.join(__dirname, '../plugins/store/package.json'),
      disabled: false
    }
  ]
}

const launch = () => {
  const config = getStorage(defaultConfig)
  config.plugins.forEach(({ pluginPath, disabled }) => {
    if (!disabled) {
      addPlugin(pluginPath)
    }
  })
}

launch()
