# public_tools

类似Alfred的快捷启动应用，提高效率的开源工具，万物皆插件。
> 使用 flutter ＋ nodejs 进行开发

![](https://s3.bmp.ovh/imgs/2022/05/08/032b37c3cd2fdeb7.png)

## 下载安装

下载后解压，把 `.app` 文件拖拽到应用程序目录

[下载地址](https://github.com/qwertyyb/public-tools/releases/latest/download/public.tools.zip)

## 应用特性

1. 开源
2. 快捷启动应用
3. 系统命令(重启，锁屏等)
4. 剪切板历史
5. 远程插件、插件商店
6. 可用 `nodejs` 方便开发插件

## 插件开发

1. 插件为 `npm包`

2. `package.json` 中应该有以下几个必填字段(name, title, subtitle, description, icon, mode, keywords)
 
 - 2.1 `name` 不支持scope形式
 - 2.2 `icon` 为网络图片，暂不支持本地图片
 - 2.3 `mode` 暂时只支持 `listView`
 - 2.4 `keywords` 数组形式，触发关键词

3. 此 `npm` 包导出 `PublicPlugin`
```typescript

interface PluginResult {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  icon: string;
}

interface PublicPluginMethods {
  // 当进入插件页面时调用
  onEnter: () => void
  // 当离开插件页面时调用
  onExit: () => void
  /**
   * 在插件中搜索时调用
   * @param keyword 关键词
   * @return 搜索结果
   */
  onSearch: (keyword: string) => Promise<PluginResult[]>
  /**
   * 当在插件中选择某个搜索结果时调用
   * @param result 搜索结果, 具体结构参考PluginResult
   * @return 返回Promise<string>，返回的字符串将作为搜索结果的详情显示在右侧
   */
  onResultSelected: (result: PluginResult) => Promise<string>
  /**
   * 当在插件中点击某个搜索结果时调用
   * @param result 搜索结果, 具体结构参考PluginResult
   */
  onResultTap: (result: PluginResult) => void
}

interface Utils {
  toast: (message: string) => Promise
  hideApp: () => Promise
  showApp: () => Promise
  updateResults: (results: PluginResult[]) => Promise
  updatePreview: (preview: string) => Promise
}

interface PublicPlugin {
  (utils: Utils) : PublicPluginMethods
}

```
4. 可输入 `dev` 进行本地调试

5. 提 PR 发布到 store, 供其他人下载

## TODO

- [ ] 更好的开发体验，能打断点调试
- [ ] 优化 `remote` 稳定性
