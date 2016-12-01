//
//  SingleCharacteristicViewController.h
//  CentralPeripheralTool
//
//  Created by LiuMingchuan on 2016/11/30.
//  Copyright © 2016年 LiuMingchuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SingleCharacteristicViewController : UIViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic;

@end
