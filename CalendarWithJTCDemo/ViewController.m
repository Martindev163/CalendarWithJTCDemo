//
//  ViewController.m
//  CalendarWithJTCDemo
//
//  Created by 马浩哲 on 16/9/20.
//  Copyright © 2016年 junanxin. All rights reserved.
//

#import "ViewController.h"
#import "common.h"

@interface ViewController ()
{
    NSMutableDictionary *_eventsByDate;
    
    NSDate *_dateSelected;//记录被选中的日期
    NSDate *_todayDate;//当前日期
    NSDate *_minDate;//最小日期
    NSDate *_maxDate;//最大日期
}

@property (nonatomic, strong) UIButton *turnToTodayBtn;
@property (nonatomic, strong) UIButton *changeModelBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    //设置事件日期
    [self createRandomEvents];
    //设置最大最小查阅日期
    [self createMinAndMaxDate];
    
    //加载日历和菜单
    [self loadMenuAndCalendar];
    //显示中文
    _calendarManager.dateHelper.calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:[NSDate date]];
}


#pragma mark - 加载菜单和日历
-(void)loadMenuAndCalendar
{
    _calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, 20, kDeviceWidth, 40)];
    _calendarMenuView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_calendarMenuView];
    
    _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, 60, kDeviceWidth, 300)];
    _calendarContentView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_calendarContentView];
    
    _turnToTodayBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_calendarContentView.frame)+20, 100, 30)];
    [_turnToTodayBtn setTitle:@"显示今天" forState:UIControlStateNormal];
    [_turnToTodayBtn setBackgroundColor:[UIColor yellowColor]];
    [_turnToTodayBtn addTarget:self action:@selector(turnTodayAction) forControlEvents:UIControlEventTouchUpInside];
    [_turnToTodayBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.view addSubview:_turnToTodayBtn];
    
    _changeModelBtn = [[UIButton alloc] initWithFrame:CGRectMake(kDeviceWidth - 120, CGRectGetMaxY(_calendarContentView.frame)+20, 100, 30)];
    _changeModelBtn.backgroundColor = [UIColor yellowColor];
    [_changeModelBtn setTitle:@"改变显示" forState:UIControlStateNormal];
    [_changeModelBtn addTarget:self action:@selector(changeModelAction) forControlEvents:UIControlEventTouchUpInside];
    [_changeModelBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.view addSubview:_changeModelBtn];
}

#pragma mark - 控制按钮的事件
-(void)turnTodayAction
{
    [_calendarManager setDate:_todayDate];
}

-(void)changeModelAction
{
    _calendarManager.settings.weekModeEnabled = !_calendarManager.settings.weekModeEnabled;
    [_calendarManager reload];
    
    CGFloat newHeight = 300;
    if (_calendarManager.settings.weekModeEnabled) {
        newHeight = 85.;
    }
    CGRect tempFrame = self.calendarContentView.frame;
    tempFrame.size.height = newHeight;
    
    self.calendarContentView.frame= tempFrame;
    
}


#pragma mark - 日历的代理方法
-(void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.hidden = NO;
    
    //如果当前页面中的日期来自于其他月份
    //按月为单位显示日期
//    if ([dayView isFromAnotherMonth]) {
//        dayView.hidden = YES;
//    }
    //今天(选中当前日)
     if ([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date])
    {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];//日期被选中的蓝色圆圈
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];//日期文字
    }
    //被选中的日期
    else if (_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date])
    {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    //其他月份
    else if (![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date])
    {
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    //当前月的其他日期,实现当前只能选中一个的效果
    else
    {
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if ([self haveEventForDay:dayView.date]) {
        dayView.dotView.hidden = NO;
    }
    else
    {
        dayView.dotView.hidden = YES;
    }
}

#pragma mark - 点击了某个日期
-(void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    
    //动画实现日期被选中效果
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView duration:0.3 options:0 animations:^{
        dayView.circleView.transform = CGAffineTransformIdentity;
        [_calendarManager reload];
    } completion:nil];
    
    // 在当前页显示上一个星期或者下一个星期
    if (_calendarManager.settings.weekModeEnabled) {
        return;
    }
    
    //当点击上个月或下个月中的一天，往前一页或者向后一页
    if (![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date])
    {
        if ([_calendarContentView.date compare:dayView.date] == NSOrderedAscending)
        {
            [_calendarContentView loadNextPageWithAnimation];
        }
        else
        {
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    NSLog(@"%@",[[self dateFormatter] stringFromDate:dayView.date]);
}


#pragma mark - 为"haveEventForDay"设置一个Key
-(NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    return dateFormatter;
}

#pragma mark - 在某一天有事情
-(BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    if (_eventsByDate[key] && [_eventsByDate[key] count] > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - 制造事件日期
-(void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for (int i = 0; i < 30; ++i) {
        //从当前日期起60日内生成30个随机日期
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand()%(3600*24*60)) sinceDate:[NSDate date]];
        //用这个日期作为eventsByDate的一个key
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        if (!_eventsByDate[key]) {
            _eventsByDate[key] = [NSMutableArray new];
        }
        [_eventsByDate[key] addObject:randomDate];
    }
}

#pragma mark - CalendarManager 代理 － 分页管理
//限制日期（可选方法）
-(BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date
{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}

-(void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    NSLog(@"向后一页");
}

-(void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar
{
    NSLog(@"向前一页");
}
#pragma mark - 设置向前（最大）向后（最小）查阅月份
-(void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    
    //最小日期向前两个月
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-2];
    //最大日期向后两个月
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:2];
}


#pragma mark - 自定义视图
//calendarBuildMenuItemView+prepareMenuItemView 设置了菜单的年月
-(UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    label.text= @"132";
    return label;
}

-(void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy MMMM";
        
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
    }
    menuItemView.text = [dateFormatter stringFromDate:date];
}

//改变了星期的字体颜色
-(UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    
    for (UILabel *label in view.dayViews) {
        label.textColor = [UIColor redColor];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:14];
    }
    return view;
}


-(UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar
{
    JTCalendarDayView *view = [JTCalendarDayView new];
    
    view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
    
    view.circleRatio = .8;//按比例设置被选中圆圈的大小
//    view.dotRatio = .1;//设置事件逗点的大小，暂时不知道怎么调，.2就超出范围了
    return view;
}
@end
