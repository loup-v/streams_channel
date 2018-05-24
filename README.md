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
  streams_channel: ^0.0.1
```
