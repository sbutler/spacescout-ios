//
//  SpotDetailsViewControllerViewController.h
//  SpotSeeker
//
//  Copyright 2012 UW Information Technology, University of Washington
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
#import <MessageUI/MessageUI.h>
#import "ViewController.h"
#import "Space.h"
#import "Favorites.h"
#import "REST.h"
#import "DisplayOptions.h"
#import "HoursFormat.h"
#import "SingleSpaceMapViewController.h"
#import "OAuthLoginViewController.h"
#import "EmailSpaceViewController.h"
#import "SpaceImagesScrollViewController.h"
#import "ReviewSpaceViewController.h"
#import "SpaceReviewsViewController.h"
#import "OverlayMessage.h"
#import <math.h>

@class FavoriteSpacesViewController;

@interface SpaceDetailsViewController : ViewController <RESTFinished, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, DisplayOptionsLoaded, UIWebViewDelegate, OAuthLogin, SaveFavorite, UIGestureRecognizerDelegate> {
    Space *spot;
    NSMutableDictionary *favorite_spots;
    IBOutlet UILabel *capacity_label;
    IBOutlet UIButton *favorite_button;
    IBOutlet UIButton *img_button_view;
    NSDictionary *config;
    REST *rest;
    NSMutableArray *environment_fields;
    NSMutableArray *equipment_fields;
}

- (IBAction) btnClickFavorite:(id)sender;
- (IBAction) btnClickReportProblem:(id)sender;
- (IBAction) btnClickImageBrowserOpen:(id)sender;
- (IBAction) btnClickShareSpace:(id)sender;

@property (nonatomic, retain) Space *spot;
@property (nonatomic, retain) IBOutlet UILabel *capacity_label;
@property (nonatomic, retain) IBOutlet UIButton *favorite_button;
@property (nonatomic, retain) NSMutableDictionary *favorite_spots;
@property (nonatomic, retain) IBOutlet UIButton *img_button_view;
@property (nonatomic, retain) REST *rest;
@property (nonatomic, retain) NSDictionary *config;
@property (nonatomic, retain) NSMutableArray *environment_fields;
@property (nonatomic, retain) NSMutableArray *equipment_fields;
@property (nonatomic, retain) UIImage *spot_image;
@property (nonatomic, retain) UIView *footer;
@property (nonatomic, retain) IBOutlet UITableView *table_view;
@property (nonatomic, retain) NSNumber *reservation_notes_height;
@property (nonatomic, retain) NSNumber *access_notes_height;
@property (nonatomic, retain) OverlayMessage *overlay;
@property (nonatomic, retain) Favorites *favorites;
@property (nonatomic) int current_image;
@property (nonatomic, retain) UITableViewCell *image_title_cell_while_building;

// To handle the return from logging in...
@property (nonatomic) bool is_marking_favorite;
@property (nonatomic) bool is_sharing_space;

// To notify this viewcontroller if we've removed a favorite
@property (nonatomic, retain) FavoriteSpacesViewController *opening_view_controller_favorites;

@end
