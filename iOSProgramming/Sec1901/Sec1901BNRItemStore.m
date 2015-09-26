//
//  Sec1901BNRItemStore.m
//  iOSProgramming
//
//  Created by palance on 15/9/26.
//  Copyright © 2015年 binglen. All rights reserved.
//

#import "Sec1901BNRItemStore.h"
#import "Sec1901BNRItem.h"
#import "Sec1901BNRImageStore.h"

@interface Sec1901BNRItemStore()
@property (nonatomic) NSMutableArray *privateItems;
@end

@implementation Sec1901BNRItemStore

#pragma mark - 存取函数
-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"Sec1901items.archive"];
}

-(BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

#pragma mark - 创建和初始化
+(instancetype)sharedStore
{
    static Sec1901BNRItemStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{sharedStore = [[self alloc]initPrivate];});
    
    //    if (sharedStore == nil) {
    //        sharedStore = [[self alloc]initPrivate];
    //    }
    return sharedStore;
}

-(instancetype)initPrivate
{
    self = [super init];
    if (self) {
        //        self.privateItems = [[NSMutableArray alloc]init];
        NSString *path = [self itemArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        // 如果之前没有保存过privateItems，就创建一个新的
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc]init];
        }
    }
    return self;
}

-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [BNRItemStore sharedStore]" userInfo:nil];
    return nil;
}

-(Sec1901BNRItem *)createItem
{
    //    Sec1101BNRItem *item = [Sec1101BNRItem randomItem];
    Sec1901BNRItem *item = [[Sec1901BNRItem alloc]init];
    [self.privateItems addObject:item];
    return item;
}

-(void)removeItem:(Sec1901BNRItem *)item
{
    NSString *key = item.itemKey;
    [[Sec1901BNRImageStore sharedStore]deleteImageForKey:key];
    [self.privateItems removeObjectIdenticalTo:item];
}

-(void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    Sec1901BNRItem *item = self.privateItems[fromIndex];
    [self.privateItems removeObjectAtIndex:fromIndex];
    
    [self.privateItems insertObject:item atIndex:toIndex];
}

-(NSArray *)allItems
{
    return self.privateItems;
}

@end
