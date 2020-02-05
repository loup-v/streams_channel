//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package app.loup.streams_channel_example;

import android.os.Handler;

import app.loup.streams_channel.StreamsChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;

public class PluginExample implements FlutterPlugin {

  public static void registerWith(PluginRegistry.Registrar registrar) {
    final StreamsChannel channel = new StreamsChannel(registrar.messenger(), "streams_channel_example");
    channel.setStreamHandlerFactory(arguments -> new StreamHandler());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final StreamsChannel channel = new StreamsChannel(binding.getBinaryMessenger(), "streams_channel_example");
    channel.setStreamHandlerFactory(arguments -> new StreamHandler());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {

  }

  // Send "Hello" 10 times, every second, then ends the stream
  public static class StreamHandler implements EventChannel.StreamHandler {

    private final Handler handler = new Handler();
    private final Runnable runnable = new Runnable() {
      @Override
      public void run() {
        if (count > 10) {
          eventSink.endOfStream();
        } else {
          eventSink.success("Hello " + count + "/10");
        }
        count++;
        handler.postDelayed(this, 1000);
      }
    };

    private EventChannel.EventSink eventSink;
    private int count = 1;

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
      System.out.println("StreamHandler - onListen: " + o);
      this.eventSink = eventSink;
      runnable.run();
    }

    @Override
    public void onCancel(Object o) {
      System.out.println("StreamHandler - onCancel: " + o);
      handler.removeCallbacks(runnable);
    }
  }
}
