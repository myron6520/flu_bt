#import <Flutter/Flutter.h>

@interface FluBtPlugin : NSObject<FlutterPlugin>
-(instancetype)initWithChannel:(FlutterMethodChannel *)channel;
@end
