#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "PluginExample.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  
  // Manually register PluginExample
  [PluginExample registerWithRegistrar:[self registrarForPlugin:@"PluginExample"]];
  
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
