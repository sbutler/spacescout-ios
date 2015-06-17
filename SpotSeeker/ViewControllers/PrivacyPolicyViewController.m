//
//  PrivacyPolicyViewController.m
//  IlliniSpaces
//
//  Created by susbutler1 on 6/16/15.
//
//

#import "PrivacyPolicyViewController.h"

@interface PrivacyPolicyViewController ()

@end

@implementation PrivacyPolicyViewController

@synthesize webview;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.side_menu = [[SideMenu alloc] init];
    [self.side_menu setOpeningViewController:self];
    [self.side_menu addSwipeToOpenMenuToView:self.view];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnClickClose:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];

    NSURL *noticeURL = [[NSBundle mainBundle] URLForResource:@"IlliniSpacesPrivacy Notice" withExtension:@"rtf"];
    NSURLRequest *request = [NSURLRequest requestWithURL:noticeURL];
    [webview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClickClose:(id)sender {
    [self.side_menu showMenu];
}

@end
