const path = require("path");
const fs = require('fs')
const npmPublish = require("@jsdevtools/npm-publish");
const { execSync } = require("child_process");

const getPluginName = (pluginPath) => {
  const { name } = require(pluginPath)
  return name
}

const modifyPluginName = (pluginPath) => {
  const name = getPluginName(pluginPath);
  const prefix = '@public-tools/plugin-';
  const newName = prefix + name;
  const pkgJson = require(pluginPath)
  fs.writeFileSync(pluginPath, JSON.stringify({
    ...pkgJson,
    name: newName,
  }, null, 2), 'utf8');
}

const publishPlugin = async (pluginPath) => {
  modifyPluginName(pluginPath);
  return npmPublish({
    package: pluginPath,
    token: process.env['NPM_TOKEN'],
    access: 'public',
  })
}

const getPluginsPath = () => {
  const pluginsPath = path.join(__dirname, '../plugins');
  const dirList = fs.readdirSync(pluginsPath);
  return dirList.map(dirName => {
    return path.join(pluginsPath, dirName, './package.json')
  }).filter(pluginDirPath => {
    return fs.existsSync(pluginDirPath)
  })
}

const publishPlugins = async () => {
  try {
    const pluginsPath = getPluginsPath()
    const list = await Promise.all(pluginsPath.map((pluginPath) => {
      return publishPlugin(pluginPath)
    }));
    const pluginsDir = path.join(__dirname, '../plugins');
    execSync(`git checkout ${pluginsDir}`)
    return list
  } catch(err) {
    const pluginsDir = path.join(__dirname, '../plugins');
    execSync(`git checkout ${pluginsDir}`)
    await new Promise(resolve => setTimeout(resolve, 1000));
    throw err
  }
}

module.exports = {
  publishPlugins
}