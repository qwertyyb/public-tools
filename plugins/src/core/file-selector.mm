#include <napi.h>
#include <stdio.h>
#include <AppKit/AppKit.h>

Napi::Value SelectFile(const Napi::CallbackInfo& info)
{
    Napi::Env env = info.Env();
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.title = [NSString stringWithUTF8String: "选择plugin.json文件"];
    openPanel.prompt = [NSString stringWithUTF8String: "选择"];
    openPanel.allowsMultipleSelection = NO;
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    NSModalResponse result = [openPanel runModal];
    if (result == NSModalResponseOK) {
        NSString* selectedPath = [[openPanel URL] path];
        printf("%s", selectedPath.UTF8String);
        return Napi::String::New(env, selectedPath.UTF8String);
    }
    return Napi::String::New(env, "");
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "selectFile"), Napi::Function::New(env, SelectFile));
  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)