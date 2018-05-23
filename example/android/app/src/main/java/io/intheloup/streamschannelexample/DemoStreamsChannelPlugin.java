package io.intheloup.streamschannelexample;

import android.os.Handler;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.intheloup.streamschannel.StreamsChannel;

public class DemoStreamsChannelPlugin {

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final StreamsChannel channel = new StreamsChannel(registrar.messenger(), "streams_channel_test");
        channel.setStreamHandler(new StreamHandler());
    }

    public static class StreamHandler implements EventChannel.StreamHandler {

        private final Handler handler = new Handler();
        private final Map<String, Runner> runners = new HashMap<>();

        @Override
        public void onListen(Object o, final EventChannel.EventSink eventSink) {
            System.out.println("StreamHandler - onListen: " + o);
            final Runner runner = new Runner(handler, eventSink);
            runners.put(o.toString(), runner);
            runner.run();
        }

        @Override
        public void onCancel(Object o) {
            System.out.println("StreamHandler - onCancel: " + o);
            handler.removeCallbacks(runners.get(o.toString()));
            runners.remove(o.toString());
        }

        public static class Runner implements Runnable {

            private final Handler handler;
            private final EventChannel.EventSink sink;

            Runner(Handler handler, EventChannel.EventSink sink) {
                this.handler = handler;
                this.sink = sink;
            }

            @Override
            public void run() {
                sink.success("Hello");
                handler.postDelayed(this, 1000);
            }

        }
    }
}
