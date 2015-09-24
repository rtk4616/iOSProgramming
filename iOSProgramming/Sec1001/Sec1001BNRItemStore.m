//
//  Sec1001BNRItemStore.m
//  iOSProgramming
//
//  Created by palance on 15/9/4.
//  Copyright (c) 2015年 binglen. All rights reserved.
//

#import "Sec1001BNRItemStore.h"
#import "Sec1001BNRItem.h"

@interface Sec1001BNRItemStore()
@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation Sec1001BNRItemStore

#pragma mark - 创建和初始化
+(instancetype)sharedStore
{
    static Sec1001BNRItemStore *sharedStore = nil;
    if (sharedStore == nil) {
        sharedStore = [[self alloc]initPrivate];
    }
    return sharedStore;
}

-(instancetype)initPrivate
{
    self = [super init];
    if (self) {
        self.privateItems = [[NSMutableArray alloc]init];
    }
    return self;
}

-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [BNRItemStore sharedStore]" userInfo:nil];
    return nil;
}

-(Sec1001BNRItem *)createItem
{
    Sec1001BNRItem *item = [Sec1001BNRItem randomItem];
    [self.privateItems addObject:item];
    return item;
}

-(void)removeItem:(Sec1001BNRItem *)item
{
    [self.privateItems removeObjectIdenticalTo:item];
}

-(void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    Sec1001BNRItem *item = self.privateItems[fromIndex];
    [self.privateItems removeObjectAtIndex:fromIndex];
    
    [self.privateItems insertObject:item atIndex:toIndex];
}

-(NSArray *)allItems
{
    return self.privateItems;
}

@end
