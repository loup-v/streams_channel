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
  streams_channel: ^0.1.0
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

```java
public class DemoPlugin {

  public static void registerWith(PluginRegistry.Registrar registrar) {
      final StreamsChannel channel = new StreamsChannel(registrar.messenger(), "some_channel");
      channel.setStreamHandler(new StreamHandler());
  }

  public static class StreamHandler implements EventChannel.StreamHandler {

    private final Handler handler = new Handler();
    private final Map<String, Runner> runners = new HashMap<>();

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        final Runner runner = new Runner(handler, eventSink);
        runners.put(o.toString(), runner);
        runner.run();
    }

    @Override
    public void onCancel(Object o) {
        handler.removeCallbacks(runners.get(o.toString()));
        runners.remove(o.toString());
    }

    // Send "Hello" 10 times, every second, then ends the stream
    public static class Runner implements Runnable {

      private final Handler handler;
      private final EventChannel.EventSink sink;
      private int count = 1;

      Runner(Handler handler, EventChannel.EventSink sink) {
          this.handler = handler;
          this.sink = sink;
      }

      @Override
      public void run() {
          if (count > 10) {
              sink.endOfStream();
          } else {
              sink.success("Hello " + count + "/10");
          }
          count++;
          handler.postDelayed(this, 1000);
      }
    }
  }
}
```

For the Objective-C code and more, see the example project.


## Author

Beacons plugin is developed by Loup, a mobile development studio based in Montreal and Paris.  
You can contact us at <hello@intheloup.io>


## License

Apache License 2.0
