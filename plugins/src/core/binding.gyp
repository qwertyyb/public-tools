{
    "targets": [{
        "target_name": "fileSelector",
        "cflags!": [ "-fno-exceptions" ],
        "cflags_cc!": [ "-fno-exceptions" ],
        "sources": ["./file-selector.mm"],
        "link_settings": {
          "libraries": [
            "-framework AppKit"
          ]
        },
        "include_dirs": [
          "<!@(node -p \"require('node-addon-api').include\")"
        ],
        'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ],
    }]
}