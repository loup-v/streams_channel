//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.streamschannelexample;

import android.os.Handler;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.intheloup.streamschannel.StreamsChannel;

public class DemoPlugin {

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final StreamsChannel channel = new StreamsChannel(registrar.messenger(), "streams_channel_test");
        channel.setStreamHandlerFactory(new StreamsChannel.StreamHandlerFactory() {
            @Override
            public EventChannel.StreamHandler create(Object arguments) {
                return new StreamHandler();
            }
        });
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
