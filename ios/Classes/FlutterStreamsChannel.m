//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

#import "FlutterStreamsChannel.h"

@interface FlutterStreamsChannelStream : NSObject
  @property(strong, nonatomic) FlutterEventSink sink;
  @property(strong, nonatomic) NSObject<FlutterStreamHandler> *handler;
@end

@implementation FlutterStreamsChannelStream

@end

@implementation FlutterStreamsChannel {
  NSObject<FlutterBinaryMessenger>* _messenger;
  NSString* _name;
  NSObject<FlutterMethodCodec>* _codec;
}
+ (instancetype)streamsChannelWithName:(NSString*)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  NSObject<FlutterMethodCodec>* codec = [FlutterStandardMethodCodec sharedInstance];
  return [FlutterStreamsChannel streamsChannelWithName:name binaryMessenger:messenger codec:codec];
}

+ (instancetype)streamsChannelWithName:(NSString*)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                               codec:(NSObject<FlutterMethodCodec>*)codec {
  return [[FlutterStreamsChannel alloc] initWithName:name binaryMessenger:messenger codec:codec];
}

- (instancetype)initWithName:(NSString*)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                       codec:(NSObject<FlutterMethodCodec>*)codec {
  self = [super init];
  NSAssert(self, @"Super init cannot be nil");
  _name = name;
  _messenger = messenger;
  _codec = codec;
  return self;
}

- (void)setStreamHandlerFactory:(NSObject<FlutterStreamHandler> *(^)(id))factory {
  if (!factory) {
    [_messenger setMessageHandlerOnChannel:_name binaryMessageHandler:nil];
    return;
  }
  
  __block NSMutableDictionary *streams = [NSMutableDictionary new];
  FlutterBinaryMessageHandler messageHandler = ^(NSData* message, FlutterBinaryReply callback) {
    FlutterMethodCall* call = [self->_codec decodeMethodCall:message];
    NSNumber *key = [self extractKeyFor:@"listen" from:call];
    
    if (key) {
      FlutterStreamsChannelStream *stream = [streams objectForKey:key];
      if(stream) {
        FlutterError* error = [stream.handler onCancelWithArguments:nil];
        if (error) {
          NSLog(@"Failed to cancel existing stream: %@. %@ (%@)", error.code, error.message,
                error.details);
        }
      }
      
      stream = [FlutterStreamsChannelStream new];
      stream.sink = ^(id event) {
        NSString *name = [NSString stringWithFormat:@"%@<%@>", self->_name, key];
        
        if (event == FlutterEndOfEventStream) {
          [self->_messenger sendOnChannel:name message:nil];
        } else if ([event isKindOfClass:[FlutterError class]]) {
          [self->_messenger sendOnChannel:name
                                  message:[self->_codec encodeErrorEnvelope:(FlutterError*)event]];
        } else {
          [self->_messenger sendOnChannel:name message:[self->_codec encodeSuccessEnvelope:event]];
        }
      };
      stream.handler = factory(call.arguments);
      
      [streams setObject:stream forKey:key];
      
      FlutterError* error = [stream.handler onListenWithArguments:call.arguments eventSink:stream.sink];
      if (error) {
        callback([self->_codec encodeErrorEnvelope:error]);
      } else {
        callback([self->_codec encodeSuccessEnvelope:nil]);
      }
      return;
    }
    
    key = [self extractKeyFor:@"cancel" from:call];
    if (key) {
      FlutterStreamsChannelStream *stream = [streams objectForKey:key];
      if(!stream) {
        callback(
                 [self->_codec encodeErrorEnvelope:[FlutterError errorWithCode:@"error"
                                                                       message:@"No active stream to cancel"
                                                                       details:nil]]);
        return;
      }
      
      [streams removeObjectForKey:key];
      
      FlutterError* error = [stream.handler onCancelWithArguments:call.arguments];
      if (error) {
        callback([self->_codec encodeErrorEnvelope:error]);
      } else {
        callback([self->_codec encodeSuccessEnvelope:nil]);
      }
      return;
    }
    
    callback(nil);
  };
  
  [_messenger setMessageHandlerOnChannel:_name binaryMessageHandler:messageHandler];
}

- (NSNumber*)extractKeyFor:(NSString*)method from:(FlutterMethodCall*)call {
  NSString *pattern = [NSString stringWithFormat:@"%@<(\\d*)>", method];
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
  NSArray *results = [regex matchesInString:call.method options:0 range:NSMakeRange(0, call.method.length)];
  
  if (results.count == 0) {
    return nil;
  }
  
  NSTextCheckingResult *match = results.firstObject;
  NSInteger callId = [[call.method substringWithRange:[match rangeAtIndex:1]] integerValue];
  return [NSNumber numberWithInteger:callId];
}

@end
