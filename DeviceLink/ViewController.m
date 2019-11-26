//
//  ViewController.m
//  DeviceLink
//
//  Created by 耿德通 on 2019/11/25.
//  Copyright © 2019 耿德通. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<MCNearbyServiceBrowserDelegate,MCNearbyServiceAdvertiserDelegate,MCSessionDelegate>

@property (nonatomic , strong) MCPeerID *peerID;
@property (nonatomic , strong) MCSession *session;
@property (nonatomic , strong) MCNearbyServiceBrowser *browser;
@property (nonatomic , strong) MCNearbyServiceAdvertiser *advertiser;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    
    self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionOptional];
    self.session.delegate = self;
    
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"DTTalk"];        //  type参数不能带有下划线？？？？
    self.browser.delegate = self;
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:@"DTTalk"];
    self.advertiser.delegate = self;
    
}

- (IBAction)clickBrowserButton:(id)sender {
//    [self presentViewController:self.browser animated:YES completion:nil];
}

- (IBAction)clickOnlineButton:(id)sender {
    if (self.advertiser && self.browser) {
        [self.advertiser startAdvertisingPeer];
        [self.browser startBrowsingForPeers];
    }
}

- (IBAction)clickHideSelfButton:(id)sender {
    if (self.advertiser && self.browser) {
        [self.advertiser stopAdvertisingPeer];
        [self.browser stopBrowsingForPeers];
    }
}

- (IBAction)clickSendButton:(id)sender {
    NSLog(@"send text");
    NSString *message = @"hello world!!!";
    
    NSMutableData *data = [[@"txt" dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [data appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

- (IBAction)tapImageView:(id)sender {
    NSLog(@"send image");
    NSMutableData *data = [[@"img" dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [data appendData:UIImagePNGRepresentation([UIImage imageNamed:@"111.png"])];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

#pragma mark - MCSessionDelegate
- (void)session:(nonnull MCSession *)session peer:(nonnull MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnecting:
        {
            NSLog(@"MCSessionStateConnecting");
        }
            break;
        case MCSessionStateConnected:
        {
            NSLog(@"MCSessionStateConnected");
        }
            break;
        case MCSessionStateNotConnected:
        {
            NSLog(@"MCSessionStateNotConnected");
        }
            break;
        default:
            break;
    }
}

- (void)session:(nonnull MCSession *)session didReceiveData:(nonnull NSData *)data fromPeer:(nonnull MCPeerID *)peerID {
    NSLog(@"接收到信息");
    
    NSString *dataType = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 3)] encoding:NSUTF8StringEncoding];
    
    if ([dataType isEqualToString:@"txt"]) {
        NSString *message = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(3, data.length - 3)] encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.messageTextView.text = [self.messageTextView.text stringByAppendingString:message];
            NSLog(@"接收到的信息 ： %@",message);
        });
    } else if ([dataType isEqualToString:@"img"]) {
        UIImage *img = [UIImage imageWithData:[data subdataWithRange:NSMakeRange(3, data.length - 3)]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.messageImageView.image = nil;
            self.messageImageView.image = img;
            NSLog(@"接收到的图片 ： %@",img);
        });
    } else {
        NSLog(@"未知类型数据");
    }
    
}

- (void)session:(nonnull MCSession *)session didReceiveStream:(nonnull NSInputStream *)stream withName:(nonnull NSString *)streamName fromPeer:(nonnull MCPeerID *)peerID {
    
}

- (void)session:(nonnull MCSession *)session didStartReceivingResourceWithName:(nonnull NSString *)resourceName fromPeer:(nonnull MCPeerID *)peerID withProgress:(nonnull NSProgress *)progress {
    
}

- (void)session:(nonnull MCSession *)session didFinishReceivingResourceWithName:(nonnull NSString *)resourceName fromPeer:(nonnull MCPeerID *)peerID atURL:(nullable NSURL *)localURL withError:(nullable NSError *)error {
    
}

#pragma mark - MCNearbyServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(nullable NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
    NSLog(@"接收到 %@ 的请求",peerID.displayName);
    invitationHandler(YES,self.session);
}


#pragma mark - MCNearbyServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
    NSLog(@"%@",browser);
    NSLog(@"%@",peerID);
    NSLog(@"%@",info);
    
    if ([self.peerID.displayName isEqualToString:@"iPhone 8 Plus"] && [peerID.displayName isEqualToString:@"星汉西流夜未央"]) {
        [browser invitePeer:peerID toSession:self.session withContext:nil timeout:0];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    
}

@end
