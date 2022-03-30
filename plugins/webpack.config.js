const CopyPlugin = require("copy-webpack-plugin");

module.exports = {
  mode: 'production',
  target: 'node',
  entry: './src/index.js',

  module: {
    rules: [
      {
        test: /\.node$/,
        loader: 'node-loader',
      },
    ],
  },

  plugins: [
    new CopyPlugin({
      patterns: [
        { from: "src/qrcode/lib/wechat_qrcode_files.data" },
      ],
    }),
  ],
}