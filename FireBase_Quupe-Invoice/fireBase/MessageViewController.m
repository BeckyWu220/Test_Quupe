//
//  MessageViewController.m
//  quupe
//
//  Created by Wanqiao Wu on 2016-10-10.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController ()
{
    NSMutableArray *messages;
    AppDelegate *appDelegate;
    Boolean firstLayout;
}

@end

@implementation MessageViewController

@synthesize ref;
@synthesize targetUID;
@synthesize targetIcon;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.navigationItem.title = @"User Name";
    NSLog(@"LALAL: %@",self.senderDisplayName);
    
    ref = [[FIRDatabase database] reference];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"transactionIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(SwitchToTransactionView)];
    self.navigationItem.rightBarButtonItem.customView.frame = CGRectMake(0, 0, 40, 40);
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    firstLayout = YES;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:@"SFUIText-Regular" size:15.0f];
    
    self.inputToolbar.contentView.textView.font = [UIFont fontWithName:@"SFUIText-Regular" size:15.0f];
    self.inputToolbar.contentView.textView.layer.borderWidth = 0;
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:15.0f];
    [sendBtn setTitleColor:[UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    UIButton *otherBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [otherBtn setImage:[UIImage imageNamed:@"addBtn"] forState:UIControlStateNormal];
    
    self.inputToolbar.contentView.rightBarButtonItem = sendBtn;
    self.inputToolbar.contentView.leftBarButtonItem = otherBtn;
    self.inputToolbar.contentView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0f];
    
    messages = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self observeMessages];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"messages"] removeAllObservers];
}

- (void)observeMessages
{
    FIRDatabaseQuery *msgQuery = [[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"messages"] queryLimitedToLast:25];
    [msgQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            NSLog(@"SNAP: %@", snapshot.key);
            
            //set current user's seen node to 0 means that current user has read all messages from the target user.
            [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"status"] child:@"seen"] setValue:@"0"];
            
            NSString *name = [snapshot.value objectForKey:@"name"];
            NSString *text = [snapshot.value objectForKey:@"text"];
            
            NSString *time = [snapshot.value objectForKey:@"time"];
            NSTimeInterval timeInterval = [time doubleValue] / 1000.0f;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
            NSLog(@"GMT TIME: %@", date);
            
            /*NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
             [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
             NSLog(@"LOCAL TIME: %@", [dateFormat stringFromDate:date]);*/
            
            [self addMessageWithName:name Text:text Date:date];
            [self finishReceivingMessage];
            
        }else{
            NSLog(@"Snapshot Not Exist in users-detail->currentUserUID->chats->seen of MessageVC.");
        }
        
    }];
    
}

- (void)addMessageWithName:(NSString *)name Text:(NSString *)text Date:(NSDate *)date
{
    JSQMessage *message;
    
    //using name to detect if it is a message send from the current user.
    //This is not a reliable way, because if a user changes his/her username, this may cause some bugs. This could be solved by changing all fields of username as a user changes his/her username. Or Adding uid for the message node.
    if ([name isEqualToString:appDelegate.currentUser.name]) {
        message = [[JSQMessage alloc] initWithSenderId:appDelegate.currentUser.uid senderDisplayName:name date:date text:text];
    }else
    {
        message = [[JSQMessage alloc] initWithSenderId:targetUID senderDisplayName:name date:date text:text];
    }
    
    [messages addObject:message];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    //[self loadMessageFromUserWithUID:targetUID];
//    //[self scrollToBottomAnimated:YES];
//    
//    [super viewWillAppear:animated];
//    [self.view layoutIfNeeded];
//    NSLog(@"LAYOUT IF NEEDED");
//    [self.collectionView.collectionViewLayout invalidateLayout];
//    
//    if (self.automaticallyScrollsToMostRecentMessage) {
//        firstLayout = YES;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            firstLayout = NO;
//        });
//    }
//}
//
//- (void)viewDidLayoutSubviews
//{
//    NSLog(@"SUBVIEW LAYOUT");
//    [super viewDidLayoutSubviews];
//    if (firstLayout && self.automaticallyScrollsToMostRecentMessage) {
//        [self scrollToBottomAnimated:NO];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [messages objectAtIndex:indexPath.item];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    JSQMessagesBubbleImage *outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0f]];
    JSQMessagesBubbleImage *incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:67.0/255.0f green:169.0/255.0f blue:242.0/255.0f alpha:1.0f]];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return outgoingBubbleImageData;
    }
    
    return incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    JSQMessagesAvatarImage *avatarImage;
    
    if ([message.senderId isEqualToString:appDelegate.currentUser.uid])
    {
        avatarImage = [JSQMessagesAvatarImage avatarWithImage:[UIImage imageNamed:@"default-profile.jpg"]];
    }else{
        avatarImage = [JSQMessagesAvatarImage avatarWithImage:targetIcon];
    }
    
    return avatarImage;*/
    return nil;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    NSString *key = [[ref child:@"messages"] childByAutoId].key;
    //The missing of img node may cause problems, need to refine later.
    NSLog(@"Send Message to: %@, messagesId: %@",appDelegate.currentUser.name, key);
    NSDictionary *msgDic = @{@"name": appDelegate.currentUser.name,
                             @"photoUrl": appDelegate.currentUser.imgURL,
                             @"text": text,
                             @"time": [FIRServerValue timestamp]};
    
    [[[[[[[ref child:@"users-detail"] child:appDelegate.currentUser.uid] child:@"chats"] child:targetUID] child:@"messages"] child:key] setValue:msgDic];
    
    [[[[[[[ref child:@"users-detail"] child:targetUID] child:@"chats"] child:appDelegate.currentUser.uid] child:@"messages"] child:key] setValue:msgDic];
    
    [[[[[[[ref child:@"users-detail"] child:targetUID] child:@"chats"] child:appDelegate.currentUser.uid] child:@"status"] child:@"seen"] setValue:@"1"];//set seen node to 1 means the target user has an unread message.
    
    [[[[ref child:@"users-detail"] child:targetUID] child:@"noti"] setValue:@"1"];
    
    [self sendBatchNotificationWithMessage:text];
    
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media Messages" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Photo", nil];
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self addPhotoMediaMessage];
            break;
            
        default:
            break;
    }
    [self finishSendingMessageAnimated:YES];
}

- (void)addPhotoMediaMessage
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"default-upload"]];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                   displayName:self.senderDisplayName
                                                         media:photoItem];
    [messages addObject:photoMessage];
}


- (void)SwitchToTransactionView
{
    TransactionViewController *transactionController = [[TransactionViewController alloc] init];
    transactionController.targetUID = targetUID;
    
    [self.navigationController pushViewController:transactionController animated:YES];
    
}

- (void)sendBatchNotificationWithMessage:(NSString *)messageText
{
    BatchClientPush * clientPush = [[BatchClientPush alloc] initWithApiKey:@"57E3E842BC993832AEFFDFDE25ED4D" restKey:@"7df47add057c4e0b181c4c0676faf69c"];
    clientPush.sandbox = NO;
    clientPush.customPayload = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"content-available", nil], @"aps", nil];
    clientPush.deeplink = appDelegate.currentUser.uid;
    clientPush.groupId = @"tests";
    clientPush.message.title = @"New Message";
    clientPush.message.body = [NSString stringWithFormat:@"%@: %@", appDelegate.currentUser.name, messageText];
    clientPush.recipients.customIds = @[targetUID];
    
    [clientPush sendWithCompletionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Batch Push Error %@", error.description);
        }else{
            NSLog(@"Batch Send Item Status Change %@", response);
            NSLog(@"LenderUID: %@", targetUID);
        }
    }];
}


@end
