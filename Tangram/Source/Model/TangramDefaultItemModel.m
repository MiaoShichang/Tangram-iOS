//
//  TangramDefaultItemModel.m
//  Tangram
//
//  Copyright (c) 2015-2017 alibaba. All rights reserved.
//

#import "TangramDefaultItemModel.h"
#import "TMUtils.h"
#import "TangramElementHeightProtocol.h"
#import "TangramElementReuseIdentifierProtocol.h"

@interface TangramDefaultItemModel()

@property (nonatomic, strong) NSMutableDictionary *bizDict;

@property (nonatomic, assign) CGRect modelRect;

@property (nonatomic, strong) NSMutableDictionary *styleDict;

@end

@implementation TangramDefaultItemModel

- (NSArray *)margin
{
    if (_margin && 4 == _margin.count) {
        return _margin;
    }
    return @[@0, @0, @0, @0];
}
- (CGFloat)marginTop
{
    return [[self.margin tm_safeObjectAtIndex:0] floatValue];
}

- (CGFloat)marginRight
{
    return [[self.margin tm_safeObjectAtIndex:1] floatValue];
}

- (CGFloat)marginBottom
{
    return [[self.margin tm_safeObjectAtIndex:2] floatValue];
}

- (CGFloat)marginLeft
{
    return [[self.margin tm_safeObjectAtIndex:3] floatValue];
}
//Default it is `inline`
- (NSString *)display
{
    if (_display.length > 0) {
        return _display;
    }
    else{
        return @"inline";
    }
    
}
- (TangramItemType *)itemType
{
    return self.type;
}
- (NSUInteger )colspan
{
    if (_colspan > 1) {
        return _colspan;
    }
    return 1;
}
//子类可选择性覆盖以下三个方法
- (CGRect)itemFrame
{
    CGRect rect = self.modelRect;
    if (self.heightFromElement > 0) {
        rect.size.height = self.heightFromElement;
    }
    if (self.widthFromStyle > 0) {
        rect.size.width = self.widthFromStyle;
    }
    if (rect.size.width > 0 && self.modelAspectRatio > 0) {
        rect.size.height = rect.size.width / self.modelAspectRatio;
    }
    if (self.heightFromStyle > 0) {
        rect.size.height = self.heightFromStyle;
    }
    return rect;
}
- (void)setItemFrame:(CGRect)itemFrame
{
    self.modelRect = itemFrame;
    
    if (self.heightFromElement <=0 && self.linkElementName.length > 0 && itemFrame.size.width > 0 && itemFrame.size.height <= 0) {
        if ([NSClassFromString(self.linkElementName) conformsToProtocol:@protocol(TangramElementHeightProtocol)]) {
            Class<TangramElementHeightProtocol> elementClass = NSClassFromString(self.linkElementName);
            if ([NSClassFromString(self.linkElementName) instanceMethodForSelector:@selector(heightByModel:)]) {
                self.heightFromElement = [elementClass heightByModel:self];
            }
        }
    }
}

- (NSString *)reuseIdentifier
{
    if (self.disableReuse) {
        return @"";
    }
    if(self.specificReuseIdentifier && self.specificReuseIdentifier.length > 0){
        return self.specificReuseIdentifier;
    }
    if ([NSClassFromString(self.linkElementName) conformsToProtocol:@protocol(TangramElementReuseIdentifierProtocol)] && [NSClassFromString(self.linkElementName) instanceMethodForSelector:@selector(reuseIdByModel:)]) {
        Class<TangramElementReuseIdentifierProtocol> elementClass = NSClassFromString(self.linkElementName);
        return [elementClass reuseIdByModel:self];
    }
    return self.type;
}
- (id)bizValueForKey:(NSString *)key;
{
    return [self.bizDict tm_safeObjectForKey:key];
}
- (id)bizValueForKey:(NSString *)key desiredClass:(__unsafe_unretained Class)aClass
{
    id value = [self.bizDict tm_safeObjectForKey:key];
    if ([value isKindOfClass:aClass]) {
        return value;
    }
    return nil;
}
- (id)styleValueForKey:(NSString *)key
{
    return [self.styleDict objectForKey:key];
}
- (id)styleValueForKey:(NSString *)key desiredClass:(__unsafe_unretained Class)aClass
{
    id value = [self.styleDict tm_safeObjectForKey:key];
    if ([value isKindOfClass:aClass]) {
        return value;
    }
    return nil;
}
- (NSArray *)bizKeys
{
    return [self.bizDict allKeys];
}

- (NSArray *)styleKeys
{
    return [self.styleDict allKeys];
}
- (NSMutableDictionary *)bizDict
{
    if (nil == _bizDict) {
        _bizDict = [[NSMutableDictionary alloc]init];
    }
    return _bizDict;
}

- (NSMutableDictionary *)styleDict
{
    if (nil == _styleDict) {
        _styleDict = [[NSMutableDictionary alloc]init];
    }
    return _styleDict;
}
- (void)setBizValue:(id)value forKey:(NSString *)key
{
    if (value && key.length > 0) {
        [self.bizDict setObject:value forKey:key];
    }
}

- (void)setStyleValue:(id)value forKey:(NSString *)key
{
    if (value && key.length > 0) {
        [self.styleDict setObject:value forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.bizDict = [aDecoder decodeObjectForKey:@"bizDict"];
        self.styleDict = [aDecoder decodeObjectForKey:@"styleDict"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.linkElementName = [aDecoder decodeObjectForKey:@"linkElementName"];
        self.margin = [aDecoder decodeObjectForKey:@"margin"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bizDict forKey:@"bizDict"];
    [aCoder encodeObject:self.styleDict forKey:@"styleDict"];
    [aCoder encodeObject:self.linkElementName forKey:@"linkElementName"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.margin forKey:@"margin"];

}
@end
