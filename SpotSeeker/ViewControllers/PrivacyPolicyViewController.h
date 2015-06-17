//
//  PrivacyPolicyViewController.h
//  IlliniSpaces
//
//  Created by susbutler1 on 6/16/15.
//
//

#import <UIKit/UIKit.h>

#import "SideMenu.h"

@interface PrivacyPolicyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, retain) SideMenu *side_menu;

-(IBAction) btnClickClose:(id)sender;

@end
