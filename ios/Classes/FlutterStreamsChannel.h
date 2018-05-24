//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

#import <Flutter/Flutter.h>

@interface FlutterStreamsChannel : NSObject

+ (instancetype)streamsChannelWithName:(NSString*)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

+ (instancetype)streamsChannelWithName:(NSString*)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                               codec:(NSObject<FlutterMethodCodec>*)codec;

- (instancetype)initWithName:(NSString*)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                       codec:(NSObject<FlutterMethodCodec>*)codec;

- (void)setStreamHandler:(NSObject<FlutterStreamHandler>* _Nullable)handler;
@end

