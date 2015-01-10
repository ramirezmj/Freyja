//
//  ChatsViewController.m
//  Freyja
//
//  Created by Jose Manuel Ramirez Martinez on 10/01/15.
//  Copyright (c) 2015 Jose Manuel Ramírez Martínez. All rights reserved.
//

#import "ChatsViewController.h"

@interface ChatsViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimers;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation ChatsViewController

- (NSMutableArray *)chats
{
    if ( !_chats ) {
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate   = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser    = [PFUser currentUser];
    PFUser *testUser1   = self.chatRoom[@"user1"];
    
    if ( [testUser1.objectId isEqual:self.currentUser.objectId] ) {
        self.withUser = self.chatRoom[@"user2"];
    }
    else {
        self.withUser = self.chatRoom[@"user1"];
    }
    
    self.title                  = self.withUser[@"profile"][@"firstName"];
    self.initialLoadComplete    = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

#pragma mark - TableView Delegate

-(void)didSendText:(NSString *)text
{
    if ( text.length != 0 ) {
        
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        
        [chat setObject:self.chatRoom    forKey:@"chatroom"];
        [chat setObject:self.currentUser forKey:@"fromUser"];
        [chat setObject:self.withUser    forKey:@"toUser"];
        [chat setObject:text             forKey:@"text"];
        
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }];
        
    }
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat          = self.chats[indexPath.row];
    PFUser *testFromUser    = chat[@"fromUser"];
    
    if ( [testFromUser.objectId isEqual:self.currentUser.objectId ] ) {
        return JSBubbleMessageTypeOutgoing;
    }
    else {
        return JSBubbleMessageTypeIncoming;
    }
}

@end
