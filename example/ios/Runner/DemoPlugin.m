//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

#import "DemoPlugin.h"
#import <streams_channel/FlutterStreamsChannel.h>

@interface StreamHandler : NSObject<FlutterStreamHandler>

@property NSMutableDictionary *timers;
@property NSMutableDictionary *counts;

@end

@implementation DemoPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  
  FlutterStreamsChannel *channel = [FlutterStreamsChannel streamsChannelWithName:@"streams_channel_test" binaryMessenger:registrar.messenger];
  [channel setStreamHandler: [StreamHandler new]];
}

@end


@implementation StreamHandler

- (id)init {
  self = [super init];
  if (self) {
    self.timers = [NSMutableDictionary new];
    self.counts = [NSMutableDictionary new];
  }
  return self;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  NSLog(@"StreamHandler - onListen: %@", arguments);
  
  NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    NSInteger count = [[self.counts objectForKey:arguments] integerValue];
    if(count == 10) {
      events(FlutterEndOfEventStream);
    } else {
      events([NSString stringWithFormat:@"Hello %ld/10", (long)count]);
      [self.counts setObject:[NSNumber numberWithInteger:count + 1] forKey:arguments];
    }
  }];
  
  [self.timers setObject:timer forKey:arguments];
  [self.counts setObject:[NSNumber numberWithInteger:1] forKey:arguments];
  
  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  NSLog(@"StreamHandler - onCancel: %@", arguments);
  
  NSTimer *timer = [self.timers objectForKey:arguments];
  [timer invalidate];
  [self.timers removeObjectForKey:arguments];
  
  return nil;
}

@end
