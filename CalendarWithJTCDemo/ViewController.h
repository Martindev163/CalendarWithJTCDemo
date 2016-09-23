//
//  ViewController.h
//  CalendarWithJTCDemo
//
//  Created by 马浩哲 on 16/9/20.
//  Copyright © 2016年 junanxin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <jtcalendar/JTCalendar.h>

@interface ViewController : UIViewController<JTCalendarDelegate>

@property (nonatomic, strong) JTCalendarMenuView *calendarMenuView;//菜单

@property (nonatomic, strong) JTHorizontalCalendarView *calendarContentView;//日历

@property (nonatomic, strong) JTCalendarManager *calendarManager;//联系菜单和日历的管理


@end

