#include <node_api.h>
#include <stdio.h>
#include <AppKit/NSOpenPanel.h>

napi_value SayHello(napi_env env, napi_callback_info info)
{
    printf("Hello World\n");
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel runModal];
    return NULL;
}

napi_value Init(napi_env env, napi_value exports)
{
    napi_status status;
    napi_value fn;

    status = napi_create_function(env, NULL, 0, SayHello, NULL, &fn);
    if (status != napi_ok)
        return NULL;

    status = napi_set_named_property(env, exports, "sayHello", fn);
    if (status != napi_ok)
        return NULL;

    return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)