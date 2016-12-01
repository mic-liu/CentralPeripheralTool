//
//  SinglePeripheralViewController.h
//  CentralPeripheralTool
//
//  Created by LiuMingchuan on 2016/11/29.
//  Copyright © 2016年 LiuMingchuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SinglePeripheralViewController : UIViewController

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral;

@end
