#include <napi.h>
#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

Napi::Value GetPinyin(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  std::string original = info[0].As<Napi::String>();

  NSMutableString *ms = [[NSMutableString alloc] initWithCString:original.c_str() encoding: NSUTF8StringEncoding];
  CFMutableStringRef stringRef = (CFMutableStringRef)ms;
  CFStringTransform(stringRef, nil, kCFStringTransformToLatin, false);
  CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false);
  
  return Napi::String::New(env, [ms cStringUsingEncoding: NSUTF8StringEncoding]);
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "getPinyin"), Napi::Function::New(env, GetPinyin));
  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
