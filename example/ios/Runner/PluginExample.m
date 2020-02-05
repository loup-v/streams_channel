//
//  PluginExample.m
//  Runner
//
//  Created by Lukasz on 2020-02-05.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "PluginExample.h"
#import <streams_channel/FlutterStreamsChannel.h>

@interface StreamHandler : NSObject<FlutterStreamHandler>
  @property(strong, nonatomic) NSTimer *timer;
  @property(assign, nonatomic) NSInteger count;
@end

@implementation PluginExample

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  
  FlutterStreamsChannel *channel = [FlutterStreamsChannel streamsChannelWithName:@"streams_channel_example" binaryMessenger:registrar.messenger];
  [channel setStreamHandlerFactory:^NSObject<FlutterStreamHandler> *(id arguments) {
    return [StreamHandler new];
  }];
}

@end

// Send "Hello" 10 times, every second, then ends the stream
@implementation StreamHandler

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  NSLog(@"StreamHandler - onListen: %@", arguments);
  
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
  NSLog(@"StreamHandler - onCancel: %@", arguments);
  
  [self.timer invalidate];
  self.timer = nil;
  
  return nil;
}

@end
