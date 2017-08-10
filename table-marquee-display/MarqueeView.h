//
//  MarqueeView.h
//  table-marquee-display
//
//  Created by kencai on 2017/8/10.
//  Copyright © 2017年 DragonPass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarqueeView : UIView

@property (nonatomic, assign) BOOL  startAnimation;
@property (nonatomic, strong) NSArray *marqueeList;

@end
