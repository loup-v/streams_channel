//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.streamschannel;

import android.annotation.SuppressLint;
import android.util.Log;

import java.nio.ByteBuffer;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler;
import io.flutter.plugin.common.BinaryMessenger.BinaryReply;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.StandardMethodCodec;

public final class StreamsChannel {
    private static final String TAG = "StreamsChannel#";

    private static final Pattern LISTEN_PATTERN = Pattern.compile("listen<(\\d*)>");
    private static final Pattern CANCEL_PATTERN = Pattern.compile("cancel<(\\d*)>");

    private final BinaryMessenger messenger;
    private final String name;
    private final MethodCodec codec;

    public StreamsChannel(BinaryMessenger messenger, String name) {
        this(messenger, name, StandardMethodCodec.INSTANCE);
    }

    public StreamsChannel(BinaryMessenger messenger, String name, MethodCodec codec) {
        assert messenger != null;
        assert name != null;
        assert codec != null;
        this.messenger = messenger;
        this.name = name;
        this.codec = codec;
    }

    public void setStreamHandler(final EventChannel.StreamHandler handler) {
        messenger.setMessageHandler(name, handler == null ? null : new IncomingStreamRequestHandler(handler));
    }

    private final class IncomingStreamRequestHandler implements BinaryMessageHandler {
        private final EventChannel.StreamHandler handler;
        private final ConcurrentHashMap<Integer, EventChannel.EventSink> activeSinks = new ConcurrentHashMap<>();

        IncomingStreamRequestHandler(EventChannel.StreamHandler handler) {
            this.handler = handler;
        }

        @Override
        public void onMessage(ByteBuffer message, final BinaryReply reply) {
            final MethodCall call = codec.decodeMethodCall(message);

            Matcher matcher = LISTEN_PATTERN.matcher(call.method);
            if (matcher.matches()) {
                onListen(Integer.parseInt(matcher.group(1)), call.arguments, reply);
                return;
            }

            matcher = CANCEL_PATTERN.matcher(call.method);
            if (matcher.matches()) {
                onCancel(Integer.parseInt(matcher.group(1)), call.arguments, reply);
                return;
            }

            reply.reply(null);
        }

        private void onListen(int id, Object arguments, BinaryReply callback) {
            final EventChannel.EventSink eventSink = new EventSinkImplementation(id);
            final EventChannel.EventSink oldSink = activeSinks.putIfAbsent(id, eventSink);
            if (oldSink != null) {
                // Repeated calls to onListen may happen during hot restart.
                // We separate them with a call to onCancel.
                try {
                    handler.onCancel(null);
                } catch (RuntimeException e) {
                    logError(id, "Failed to close existing event stream", e);
                }
            }
            try {
                handler.onListen(arguments, eventSink);
                callback.reply(codec.encodeSuccessEnvelope(null));
            } catch (RuntimeException e) {
                activeSinks.remove(id);
                logError(id, "Failed to open event stream", e);
                callback.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
            }
        }

        private void onCancel(int id, Object arguments, BinaryReply callback) {
            final EventChannel.EventSink oldSink = activeSinks.remove(id);
            if (oldSink != null) {
                try {
                    handler.onCancel(arguments);
                    callback.reply(codec.encodeSuccessEnvelope(null));
                } catch (RuntimeException e) {
                    logError(id, "Failed to close event stream", e);
                    callback.reply(codec.encodeErrorEnvelope("error", e.getMessage(), null));
                }
            } else {
                callback.reply(codec.encodeErrorEnvelope("error", "No active stream to cancel", null));
            }
        }

        private void logError(int id, String message, Throwable e) {
            Log.e(TAG + name, String.format("%s [id=%d]", message, id), e);
        }

        private final class EventSinkImplementation implements EventChannel.EventSink {

            final int id;
            final String name;
            final AtomicBoolean hasEnded = new AtomicBoolean(false);

            @SuppressLint("DefaultLocale")
            private EventSinkImplementation(int id) {
                this.id = id;
                this.name = String.format("%s<%d>", StreamsChannel.this.name, id);
            }

            @Override
            public void success(Object event) {
                if (hasEnded.get() || activeSinks.get(id) != this) {
                    return;
                }
                StreamsChannel.this.messenger.send(name, codec.encodeSuccessEnvelope(event));
            }

            @Override
            public void error(String errorCode, String errorMessage, Object errorDetails) {
                if (hasEnded.get() || activeSinks.get(id) != this) {
                    return;
                }
                StreamsChannel.this.messenger.send(
                        name,
                        codec.encodeErrorEnvelope(errorCode, errorMessage, errorDetails));
            }

            @Override
            public void endOfStream() {
                if (hasEnded.getAndSet(true) || activeSinks.get(id) != this) {
                    return;
                }
                StreamsChannel.this.messenger.send(name, null);
            }
        }
    }
}