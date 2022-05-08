{
    "targets": [{
        "target_name": "pinyin",
        "sources": ["./native/pinyin.mm"],
        "defines": [ "NAPI_DISABLE_CPP_EXCEPTIONS" ],
        "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
        "cflags!": ["-fno-exceptions"],
        "cflags_cc!": ["-fno-exceptions"],
        "xcode_settings": {
          'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
          'CLANG_CXX_LIBRARY': 'libc++',
          "OTHER_CFLAGS": ["-x objective-c++ -mmacosx-version-min=10.9"]
        },
        "link_settings": {
          "conditions": [
            [
              "OS==\"mac\"",
              {
                "libraries": ["Foundation.framework", "CoreFoundation.framework"]
              }
            ]
          ]
        }
    }]
}