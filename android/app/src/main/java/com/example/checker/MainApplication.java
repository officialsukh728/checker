package com.checker.device;

import com.rmawatson.flutterisolate.FlutterIsolatePlugin;

import io.flutter.app.FlutterApplication;

public class MainApplication extends FlutterApplication {
    public MainApplication() {
        FlutterIsolatePlugin.setCustomIsolateRegistrant(CustomPluginRegistrant.class);
    }
}