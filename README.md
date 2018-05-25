# StreamsChannel for Flutter plugin development

StreamsChannel is inspired from EventChannel. It allows to create streams of events between Flutter and platform side.

## Rationale

EventChannel allows to only create a single open stream per channel.
On the first subscription, the stream will be open and it's possible to pass arguments from Flutter to platform side. Subsequent subscriptions will either re-use the open stream or override it with a new one.

In order to have multiple streams open at the same time, with different parameters for stream initialization, one has to create multiple EventChannel. And it gets complicated if the number of streams is dynamic.

## Installation

Add streams_channel to your pubspec.yaml:

```yaml
dependencies:
  streams_channel: ^0.2.1
```

## Example

### Flutter side

```dart
final StreamsChannel channel = new StreamsChannel('some_channel');

// continuous stream of events from platform side, match some args
channel.receiveBroadcastStream('some args')
  .listen((data) {
    // do something
  });

// another continuous stream of events from platform side, matching some other args
channel.receiveBroadcastStream('some other args')
  .listen((data) {
    // do something
  });
```

Both streams are independent.  
On each stream, first subscription will trigger `onListen` on platform side, and last subscription cancelling will trigger `onCancel`.


### Platform side

#### Android

```java
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
      this.eventSink = eventSink;
      runnable.run();
    }

    @Override
    public void onCancel(Object o) {
      handler.removeCallbacks(runnable);
    }
  }
}
```

#### iOS

```objective-c
@interface StreamHandler : NSObject<FlutterStreamHandler>
  @property(strong, nonatomic) NSTimer *timer;
  @property(assign, nonatomic) NSInteger count;
@end

@implementation DemoPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

  FlutterStreamsChannel *channel = [FlutterStreamsChannel streamsChannelWithName:@"streams_channel_test" binaryMessenger:registrar.messenger];
  [channel setStreamHandlerFactory:^NSObject<FlutterStreamHandler> *(id arguments) {
    return [StreamHandler new];
  }];
}

@end

// Send "Hello" 10 times, every second, then ends the stream
@implementation StreamHandler

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  self.count = 1;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    if(self.count > 10) {
      events(FlutterEndOfEventStream);
    } else {
      events([NSString stringWithFormat:@"Hello %ld/10", (long)self.count]);
      self.count++;
    }
  }];

  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  [self.timer invalidate];
  self.timer = nil;
  return nil;
}
@end
```


## Author

Beacons plugin is developed by Loup, a mobile development studio based in Montreal and Paris.  
You can contact us at <hello@intheloup.io>


## License

Apache License 2.0
