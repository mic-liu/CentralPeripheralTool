//
//  PeripheralViewController.m
//  BluetoothDemo
//
//  Created by LiuMingchuan on 2016/11/26.
//  Copyright © 2016年 LiuMingchuan. All rights reserved.
//

#import "PeripheralViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralViewController ()<CBPeripheralManagerDelegate>

@property (strong,nonatomic)CBPeripheralManager *peripheralManager;
@property (strong,nonatomic)NSMutableArray *centralList;
@property (strong,nonatomic)CBMutableService *service;
@property (strong,nonatomic)CBMutableCharacteristic *characteristic;
@property (strong,nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIButton *startPeripheralBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateCharacteristicBtn;
@property (weak, nonatomic) IBOutlet UITextView *logTxtV;

@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Peripheral"];

    if([[[UIDevice currentDevice]systemVersion]floatValue]>7.0){
        [self.navigationController.navigationBar setTranslucent:NO];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [_startPeripheralBtn addTarget:self action:@selector(startPeripheralBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_updateCharacteristicBtn addTarget:self action:@selector(updateCharacteristicBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - 打开外围设备
- (void)startPeripheralBtnAction:(id)sender {
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
        _centralList = [NSMutableArray array];
    }
}

#pragma mark - 使用计时器开始更新特征值
- (void)updateCharacteristicBtnAction:(id)sender {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autoMakeRate) userInfo:nil repeats:YES];
    } else {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)autoMakeRate {
    if (_peripheralManager) {
        NSString *value = [NSString stringWithFormat:@"%@：%d",[NSDate date],arc4random()%30+60];
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
        [_peripheralManager updateValue:data forCharacteristic:_characteristic onSubscribedCentrals:nil];
        
        [self showLogMsg:[NSString stringWithFormat:@"新值 %@",value]];
    } else {
        [self showLogMsg:@"未打开周边模式"];
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBManagerStatePoweredOn:
            //
            [self setUpService];
            break;
        case CBManagerStatePoweredOff:
            [self showLogMsg:@"蓝牙未打开"];
            break;
            
        default:
            //不支持BLE
            [self showLogMsg:@"设备不支持BLE"];
            _peripheralManager = nil;
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    [self showLogMsg:[NSString stringWithFormat:@"中心：%@ 订阅特征：%@。",central.identifier.UUIDString,characteristic.UUID]];
    if (![_centralList containsObject:central]) {
        [_centralList addObject:central];
    }
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    [self showLogMsg:[NSString stringWithFormat:@"中心：%@ 取消订阅特征：%@。",central.identifier.UUIDString,characteristic.UUID]];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    [self showLogMsg:@"Central Read Data From Peripheral"];
    [self showLogMsg:[[NSString alloc]initWithData:request.value encoding:NSUTF8StringEncoding]];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    [self showLogMsg:@"Receive Data From Peripheral"];
    CBATTRequest *request = requests.lastObject;
    [self showLogMsg:[[NSString alloc]initWithData:request.value encoding:NSUTF8StringEncoding]];
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSDictionary *dic = @{CBAdvertisementDataLocalNameKey:@"Ryoma's Peripheral"};
    [_peripheralManager startAdvertising:dic];
    
    [self showLogMsg:@"想周边添加了服务"];
}

-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    [self showLogMsg:@"开始广播。。。。。。"];
}


#pragma mark - Log信息显示
- (void)showLogMsg:(NSString *)logMsg {
    if ([@"" isEqualToString:_logTxtV.text]) {
        _logTxtV.text = [NSString stringWithFormat:@">>%@",logMsg];
    } else {
        _logTxtV.text = [NSString stringWithFormat:@"%@\n>>%@",_logTxtV.text,logMsg];
    }
    [_logTxtV scrollRangeToVisible:NSMakeRange(_logTxtV.text.length, 1)];
    _logTxtV.layoutManager.allowsNonContiguousLayout = NO;
}

#pragma mark - 服务设定
- (void)setUpService {
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:@"18035BA8-C04C-4CBF-93F4-FB2BB5ACFC46"];
    _characteristic = [[CBMutableCharacteristic alloc]initWithType:characteristicUUID properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteEncryptionRequired];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:@"C03D84A9-F731-4B38-9486-DCA7387A9753"];
    _service = [[CBMutableService alloc]initWithType:serviceUUID primary:YES];
    [_service setCharacteristics:@[_characteristic]];
    
    [_peripheralManager addService:_service];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [_timer invalidate];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
