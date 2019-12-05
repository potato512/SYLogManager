//
//  SYLogFile.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2019/4/15.
//  Copyright © 2019年 zhangshaoyu. All rights reserved.
//

#import "SYLogFile.h"
#import <UIKit/UIKit.h>

static NSString *const logFile = @"SYLogFile.plist";

@interface SYLogModel ()

@property (nonatomic, assign) NSString *logTime;
@property (nonatomic, strong) NSString *logText;
@property (nonatomic, strong) NSString *logKey;

@end

@implementation SYLogModel

- (instancetype)initWithlog:(NSString *)text key:(NSString *)key
{
    self = [super init];
    if (self) {
        self.logText = text;
        self.logKey = (key.length > 0 ? key : @"");
        //
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSString *time = [formatter stringFromDate:NSDate.date];
        self.logTime = time;
        //
        CGFloat height = [self heightWithText:text];
        self.height = height;
        //
        NSAttributedString *attribute = [self attributeStringWithTime:time text:text key:key];
        self.attributeString = attribute;
    }
    return self;
}

- (CGFloat)heightWithText:(NSString *)text
{
    CGFloat heigt = heightText;
    if (text && [text isKindOfClass:NSString.class] && text.length > 0) {
        if (7.0 <= [UIDevice currentDevice].systemVersion.floatValue) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            CGSize size = [text boundingRectWithSize:CGSizeMake(widthText, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
            CGFloat heightTmp = size.height;
            heightTmp += 25;
            if (heightTmp < heightText) {
                heightTmp = heightText;
            }
            heigt = heightTmp;
        }
    }
    return heigt;
}

static NSString *const keyStyle = @"--";
- (NSAttributedString *)attributeStringWithTime:(NSString *)time text:(NSString *)text key:(NSString *)key
{
    NSString *string = [NSString stringWithFormat:@"%@ %@ %@\n%@", time, keyStyle, key, text];
    NSMutableAttributedString *logString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange rang = [string rangeOfString:key];
    if (rang.location == NSNotFound) {
        rang = [string rangeOfString:keyStyle];
    }
    [logString addAttribute:NSForegroundColorAttributeName value:UIColor.yellowColor range:NSMakeRange(0, (rang.location + rang.length))];
    return logString;
}


@end

#pragma mark - 文件管理

@interface SYLogFile ()

@end

@implementation SYLogFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (SYLogModel *)logWith:(NSString *)text key:(NSString *)key
{
    @synchronized (self) {
        SYLogModel *model = [[SYLogModel alloc] initWithlog:text key:key];
        [self.logArray addObject:model];
        [self saveLog:model];
        return model;
    };
}

- (void)clear
{
    @synchronized (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.logArray removeAllObjects];
            [self deleteLog];
        });
    };
}

- (NSMutableArray *)logArray
{
    if (_logArray == nil) {
        _logArray = [[NSMutableArray alloc] init];
    }
    return _logArray;
}

#pragma mark - 存储

- (void)saveLog:(SYLogModel *)model
{
    
}

- (void)deleteLog
{
    
}

- (void)read
{
    
}

@end
