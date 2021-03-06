//
//  Sec1101BNRItemsViewController.m
//  iOSProgramming
//
//  Created by palance on 15/9/4.
//  Copyright (c) 2015年 binglen. All rights reserved.
//

#import "Sec1101BNRItemsViewController.h"
#import "InformationViewController.h"
#import "Sec1101BNRItemStore.h"
#import "Sec1101BNRItem.h"
#import "Sec1101BNRDetailViewController.h"

@interface Sec1101BNRItemsViewController()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@end
@implementation Sec1101BNRItemsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Sec1101UITableViewCell"];
    [self.tableView setTableHeaderView:self.headerView];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"•••" style:UIBarButtonItemStylePlain target:self action:@selector(showInformation:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(IBAction)showInformation:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    InformationViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InformationViewController"];
    vc.informationString = @"启用相机需要用到UIImagePickerController，共分三部：一、设置sourceType；二、设置委托关系；三、弹出界面。在takePicture方法中插入如下代码：\n\
    - (IBAction)takePicture:(id)sender {\n\
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];\n\
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {\n\
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;\n\
        }else{\n\
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;\n\
        }\n\
        imagePicker.delegate = self;\n\
        [self presentViewController:imagePicker animated:YES completion:nil];\n\
    }\n\
    其中if-else判断主要用于检查当前设备是否支持相机，如果不支持则打开相册。设置委托关系要求self必须遵守UINavigationControllerDelegate和UIImagePickerControllerDelegate协议，这样，当选择了一张照片后，被委托方会收到imagePickerController:didFinishPickingMediaWithInfo:消息；如果取消选择，则收到imagePickerControllerDidCancel:消息。最后一步弹出一个模态对话框，即相册或相机。\n\
    imagePickerController:didFinishPickingMediaWithInfo:消息的处理：\n\
    -(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info\n\
    {\n\
        // 获取照片\n\
        UIImage *image = info[UIImagePickerControllerOriginalImage];\n\
        self.imageView.image = image;\n\
        // 关闭UIImagePickerController对象\n\
        [self dismissViewControllerAnimated:YES completion:nil];\n\
    }\n\
    关于编辑照片，可将imagePicker.allowsEditing = YES;\n\
    并在接收照片时 UIImage *image = info[UIImagePickerControllerEditedImage];\n\
    \n\
    在取景窗中画十字需要给imagePicker.cameraOverlayView设置一个新的UIView，并覆盖UIView的drawRect方法，在里面画十字。之后必须覆盖该view的pointInside:withEvent方法，否则在edit模式里，这个overlayView会阻挡移动和拖拽手势：\n\
    -(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event\n\
    {\n\
        return NO;\n\
    }\n\
    注意，如果当前imagePicker的sroucetType不是相机，千万不要设置cameraOverlayView，否则会崩溃！\n\n\
    关于对齐，storyboard右下角前两个角标分别用于几个控件之间看齐，以及单独定义一个控件的上下左右和长宽尺寸。\n\n\
    \n\n\
    关于转屏，需要完成两步：1、覆盖vc的supportedInterfaceOrientations方法，返回该vc支持的转屏方向；2、覆盖vc的willAnimateRotationToInterfaceOrientation:duration:方法，完成转屏后策略。但是在ios8以后，苹果推翻了之前的尺寸及屏幕方向的概念，推出了Size Classes，willAnimationRotationToInterfaceOrientation:duration:方法也被废弃掉，取而代之的是-(void)viewWillTransitionToSize: withTransitionCoordinator:参数也完全不同，需要研究新的方法以及配套的使用\n\n\
    关于线程安全的单例：需要把之前\n\
    if(!sharedStore){\n\
        sharedStore = [[self alloc]initPrivate];\n\
    }\n\
    改为\n\
    static dispatch_once_t onceToken;\n\
    dispatch_once(&onceToken, ^{sharedStore = [[self alloc ]initPrivate ];});\n\
    \n\n\
    Archiving关键点：1、要求对象遵守NSCoding协议；2、实现两个方法：encodeWithCoder:和initWithCoder。如下：\n\
    @protocol NSCoding\n\
    -(void)encodeWithCoder:(NSCoder*) aCoder;\n\
    -(void)initWithCoder:(NSCoder*) aDecoder;\n\
    @end\n\
    对于遵循该协议的对象，应调用aCoder的encodeObject:forKey:，该函数会再调用NSCoding对象的encodeWithCoder。\n\
    3、通过NSKeyedArchiver与NSKeyedUnarchiver将encode的结果存入文件。调用NSKeyedArchiver的类方法archiveRootObject:toFile保存到文件。该方法的工作原理为：i)先建立一个NSKeyedArchiver对象（它是抽象类NSCoder的具体实现子类）。ii)archiveRootObject:toFile会向rootObject发送encodeWithCoder:消息，并传入NSKeyedArchiver对象。iii)将编码存入指定文件。读取的时候则需要调用NSKyeedUnarchiver的类方法unarchiveObjectWithFile:\n\
    应用沙盒的五个路径：1、应用程序包；2、Documents/；3、Library/Caches/；4、Library/Preferences/；5、tmp/\n\
    \n\n\
    关于NSNotificationCenter，通知回调函数在被调用时与主线程之间的关系是怎样的？通知可以跨进程么？为什么设备方向发生变化时要用通知？之前讲到的自动转屏不是专门的处理方案么？\n\n\
    本章作业，要求把文件保存成PNG，只需要在将UIImage转成图片时，把函数UIImageJPEGRepresentation改为UIImagePNGRepresentation即可。\n\
    ";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDateSource方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[Sec1101BNRItemStore sharedStore] allItems] count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Sec1101UITableViewCell" forIndexPath:indexPath];
    
    NSArray *items = [[Sec1101BNRItemStore sharedStore] allItems];
    if (indexPath.row == items.count) {
        cell.textLabel.text = @"No more items!";
    }else{
        Sec1101BNRItem *item = items[indexPath.row];
        cell.textLabel.text = [item description];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[Sec1101BNRItemStore sharedStore]allItems];
        if (indexPath.row == items.count) {
            return;
        }
        Sec1101BNRItem *item = items[indexPath.row];
        [[Sec1101BNRItemStore sharedStore]removeItem:item];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[Sec1101BNRItemStore sharedStore]moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

#pragma mark - 响应header view 按钮消息
- (IBAction)toggleEditingMode:(id)sender {
    if (self.isEditing) {
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        [self setEditing:NO animated:YES];
    }else{
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        [self setEditing:YES animated:YES];
    }
}

- (IBAction)addNewItem:(id)sender {
    Sec1101BNRItem *newItem = [[Sec1101BNRItemStore sharedStore]createItem];
    
    Sec1101BNRDetailViewController *detailViewController = [[Sec1101BNRDetailViewController alloc]initForNewItem:YES];
    detailViewController.item = newItem;
    detailViewController.dismissBlock = ^{[self.tableView reloadData];};
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:detailViewController];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
//    navController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    self.definesPresentationContext = YES;
//    navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:navController animated:YES completion:nil];
    
//    NSInteger lastRow = [[[Sec1101BNRItemStore sharedStore]allItems]indexOfObject:newItem];
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark - UITableViewDelegate 方法
-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSArray *items = [[Sec1101BNRItemStore sharedStore]allItems];
    if (sourceIndexPath.row == items.count) {
        return sourceIndexPath;
    }
    if (proposedDestinationIndexPath.row == items.count) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[Sec1101BNRItemStore sharedStore]allItems];
    if (indexPath.row == items.count) {
        return;
    }
    Sec1101BNRItem *item = items[indexPath.row];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    Sec1101BNRDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Sec1101BNRDetailViewController"];
    Sec1101BNRDetailViewController *vc = [[Sec1101BNRDetailViewController alloc]initForNewItem:NO];
    vc.item = item;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
