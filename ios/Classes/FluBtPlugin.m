#import "FluBtPlugin.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface FluBtPlugin()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *manager;
    NSMutableDictionary<NSString*,CBPeripheral*> *peripherals;
    NSMutableDictionary<CBPeripheral*,NSArray<CBCharacteristic*>*>* writeCharacteristics;
    NSMutableDictionary<CBPeripheral*,NSArray<CBCharacteristic*>*>* writeWithoutResponseCharacteristics;
}
@property(nonatomic,strong)FlutterMethodChannel *channel;
@end
@implementation FluBtPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flu_bt"
            binaryMessenger:[registrar messenger]];
  FluBtPlugin* instance = [[FluBtPlugin alloc] initWithChannel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

-(instancetype)initWithChannel:(FlutterMethodChannel *)channel{
    if(self = [super init]){
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.channel = channel;
        peripherals = [NSMutableDictionary dictionary];
        writeCharacteristics = [NSMutableDictionary dictionary];
        writeWithoutResponseCharacteristics = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)invokeMethod:(NSString *)method arguments:(id)arguments{
    [self.channel invokeMethod:method arguments:arguments];
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([@"getPlatformVersion" isEqualToString:call.method]){
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        return;
    }
    if([@"getCentralState" isEqualToString:call.method]){
        result(@(manager.state));
        return;
    }
    if([@"gotoSettings" isEqualToString:call.method]){
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
        return;
    }
    if([@"startScan" isEqualToString:call.method]){
        if(manager.state != CBManagerStatePoweredOn){
            result(@{@"status":@NO,@"code":@1001,@"msg":@"蓝牙未开启"});
            return;
        }
        if(manager.isScanning){
            result(@{@"status":@YES});
            return;
        }
        [manager scanForPeripheralsWithServices:nil options:nil];
        result(@{@"status":@YES});
        return;
    }
    if([@"stopScan" isEqualToString:call.method]){
        if(manager.isScanning){
            [manager stopScan];
        }
        result(@{@"status":@YES});
        return;
    }
    if([@"connect" isEqualToString:call.method]){
        NSString *uuid = ((NSDictionary *)call.arguments)[@"uuid"];
        CBPeripheral *peripheral = peripherals[uuid];
        
        if(!peripheral){
            result(@{@"status":@NO,@"code":@1,@"msg":@"找不到外设"});
            return;
        }
        if(peripheral.state == CBPeripheralStateConnected||peripheral.state == CBPeripheralStateConnecting){
            result(@{@"status":@NO,@"code":@2,@"msg":@"已连接或者正在连接中，无需发起再次连接"});
            return;
        }
        [manager connectPeripheral:peripheral options:nil];
        [self postPeripheralState:peripheral];
        result(@{@"status":@YES,@"code":@0,@"msg":@"操作成功"});
        return;
    }
    if([@"disconnect" isEqualToString:call.method]){
        NSString *uuid = ((NSDictionary *)call.arguments)[@"uuid"];
        CBPeripheral *peripheral = peripherals[uuid];
        
        if(!peripheral){
            result(@{@"status":@NO,@"code":@1,@"msg":@"找不到外设"});
            return;
        }
        if(peripheral.state == CBPeripheralStateDisconnected||peripheral.state == CBPeripheralStateDisconnecting){
            result(@{@"status":@NO,@"code":@2,@"msg":@"不在连接中或者正在断开连接"});
            return;
        }
        [manager cancelPeripheralConnection:peripheral];
        [self postPeripheralState:peripheral];
        result(@{@"status":@YES,@"code":@0,@"msg":@"操作成功"});
        return;
    }
    if([@"write" isEqualToString:call.method]){
        NSString *uuid = ((NSDictionary *)call.arguments)[@"uuid"];
        NSString *characteristicUUID = ((NSDictionary *)call.arguments)[@"characteristicUUID"];
        FlutterStandardTypedData *data = ((NSDictionary *)call.arguments)[@"data"];
        CBPeripheral *peripheral = peripherals[uuid];
        
        if(!peripheral){
            result(@{@"status":@NO,@"code":@1,@"msg":@"找不到外设"});
            return;
        }
        if(peripheral.state == CBPeripheralStateDisconnected||peripheral.state == CBPeripheralStateDisconnecting){
            result(@{@"status":@NO,@"code":@2,@"msg":@"不在连接中或者正在断开连接"});
            return;
        }
        NSMutableArray *arr = [NSMutableArray array];
        NSArray *wnr = writeWithoutResponseCharacteristics[peripheral];
        NSArray *wr = writeCharacteristics[peripheral];
        
        if(wnr){
            [arr addObjectsFromArray:wnr];
        }
        if(wr){
            [arr addObjectsFromArray:wr];
        }
        if(arr.count<=0){
            result(@{@"status":@NO,@"code":@3,@"msg":@"找不到写特征"});
            return;
        }
        
        CBCharacteristic *characteristic = [arr firstObject];
        if(!characteristicUUID&&![characteristicUUID isEqualToString:@""]){
            for (CBCharacteristic * item in arr) {
                if([item.UUID.UUIDString isEqualToString:characteristicUUID]){
                    characteristic = item;
                    break;
                }
            }
        }
        BOOL isWNR = (characteristic.properties &CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse;
        [peripheral writeValue:data.data forCharacteristic:characteristic type:isWNR?CBCharacteristicWriteWithoutResponse:CBCharacteristicWriteWithResponse];
        result(@{@"status":@YES,@"code":@0,@"msg":@"操作成功"});
        return;
    }
    result(FlutterMethodNotImplemented);
}
-(void)postPeripheralState:(CBPeripheral *)peripheral{
    [self invokeMethod:@"peripheralStateChanged" arguments:@{
        @"uuid":peripheral.identifier.UUIDString,
        @"state":@(peripheral.state),
    }];
}
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    [self invokeMethod:@"centralStateChanged" arguments:@(central.state)];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString *uuid = peripheral.identifier.UUIDString;
    peripherals[uuid] = peripheral;
    [self invokeMethod:@"didDiscoverPeripheral" arguments:@[@{
        @"name":peripheral.name == nil?@"":peripheral.name,
        @"rssi":RSSI,
        @"uuid":peripheral.identifier.UUIDString,
    }]];
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self postPeripheralState:peripheral];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self postPeripheralState:peripheral];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSArray *wirteArr = writeCharacteristics[peripheral];
    NSMutableArray *wirteCharacteristicArr = [NSMutableArray array];
    if(wirteArr){
        [wirteCharacteristicArr addObjectsFromArray:wirteArr];
    }
    NSArray *wirteWithoutResponseArr = writeWithoutResponseCharacteristics[peripheral];
    NSMutableArray *wirteWithoutResponseCharacteristicArr = [NSMutableArray array];
    if(wirteWithoutResponseArr){
        [wirteWithoutResponseCharacteristicArr addObjectsFromArray:wirteWithoutResponseArr];
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if((characteristic.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify){
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if((characteristic.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite){
            [wirteCharacteristicArr addObject:characteristic];
        }
        if((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse){
            [wirteWithoutResponseCharacteristicArr addObject:characteristic];
        }
    }
    writeCharacteristics[peripheral] = wirteCharacteristicArr;
    writeWithoutResponseCharacteristics[peripheral] = wirteWithoutResponseCharacteristicArr;
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [self invokeMethod:@"didReceiveData" arguments:@{
        @"uuid":peripheral.identifier.UUIDString,
        @"characteristicUUID":characteristic.UUID.UUIDString,
        @"data":characteristic.value,
    }];
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        NSLog(@"写入数据失败:%@ 到特征:%@ 错误：%@",characteristic.value,characteristic.UUID.UUIDString,error);
        NSArray *writeArr = writeCharacteristics[peripheral];
        if(writeArr){
            NSMutableArray *arr = [NSMutableArray arrayWithArray:writeArr];
            [arr removeObject:characteristic];
            writeCharacteristics[peripheral] = arr;
        }
        NSArray *writeNoResArr = writeWithoutResponseCharacteristics[peripheral];
        if(writeNoResArr){
            NSMutableArray *arr = [NSMutableArray arrayWithArray:writeNoResArr];
            [arr removeObject:characteristic];
            writeWithoutResponseCharacteristics[peripheral] = arr;
        }
    }else{
        NSLog(@"已写入数据:%@ 到特征:%@",characteristic.value,characteristic.UUID.UUIDString);
    }
}
@end
