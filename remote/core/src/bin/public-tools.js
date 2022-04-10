#!/usr/bin/env node
const { getStorage, addPlugin } = require('..')

const launch = () => {
  const config = getStorage(defaultConfig)
  config.plugins.forEach(({ pluginPath, disabled }) => {
    if (!disabled) {
      addPlugin(pluginPath)
    }
  })
}

launch()
