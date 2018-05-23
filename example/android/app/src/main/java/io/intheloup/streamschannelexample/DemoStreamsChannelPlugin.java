package io.intheloup.streamschannelexample;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.intheloup.streamschannel.StreamsChannel;

public class DemoStreamsChannelPlugin {

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final StreamsChannel channel = new StreamsChannel(registrar.messenger(), "streams_channel_test");
        channel.setStreamHandler(new Handler());
    }

    public static class Handler implements EventChannel.StreamHandler {
        public Handler() {
            System.out.println("Handler - init");
        }

        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {
            System.out.println("Handler - onListen: " + o);
        }

        @Override
        public void onCancel(Object o) {
            System.out.println("Handler - onCancel: " + o);
        }
    }
}
