//
//  EmailSpaceViewController.m
//  SpaceScout
//
//  Created by Patrick Michaud on 3/4/14.
//
//

#import "EmailSpaceViewController.h"


@implementation EmailSpaceViewController

@synthesize space;
@synthesize is_sending_email;
@synthesize building_label;
@synthesize room_label;
@synthesize email_list;
@synthesize existing_emails;
@synthesize to_cell_size;
@synthesize has_valid_to_email;

const CGFloat MARGIN_LEFT = 42.0;
const CGFloat MARGIN_RIGHT = 0.0;
const CGFloat MARGIN_TOP = 11.0;
const CGFloat TEXT_FIELD_LIMIT = 0.75;
const CGFloat TEXTFIELD_Y_INSET = 3.5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    email_list = [[NSMutableArray alloc] init];
    existing_emails = [[NSMutableDictionary alloc] init];
    has_valid_to_email = FALSE;
    
    room_label.text = self.space.name;
    building_label.text = [NSString stringWithFormat:@"%@, %@", space.building_name, space.floor];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isValidEmail:(NSString *)email {
    NSString *email_regex = @".+@.+\\...+";
    NSPredicate *email_predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", email_regex];

    return [email_predicate evaluateWithObject:email];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *new_text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *from;
    
    BOOL has_error = FALSE;
   
    // Validate to field.
    if (!self.has_valid_to_email) {
        // If we don't have one in the list, and this is the field that's being edited, validate it.
        if (100 == textField.tag) {
            if (![self isValidEmail:new_text]) {
                has_error = TRUE;
            }
        }
        else {
            has_error = TRUE;
        }
    }

    // Validate from
    if (102 == textField.tag) {
        from = new_text;
    }
    else {
        from = ((UITextField *)[self.view viewWithTag:102]).text;
    }
    
    if (![self isValidEmail:from]) {
        has_error = TRUE;
    }

    // Show/hide button
    UIBarButtonItem *send_button = self.navigationItem.rightBarButtonItem;
    if (has_error) {
        send_button.enabled = FALSE;
    }
    else {
        send_button.enabled = TRUE;
    }

    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self addEmailFromTextField];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self addEmailFromTextField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case 100: {
            if (textField.text && ![textField.text isEqualToString:@""]) {
                [self addEmailFromTextField];
                [self makeEmailFieldFirstResponder];
                return NO;
            }
            // If there's content in the to field, add the email address.
            // Otherwise: From Email to From
            UITextView *from_field = (UITextView *)[self.view viewWithTag:102];
            [from_field becomeFirstResponder];
            break;
        }
        case 102: {
            // From From to Subject
            UITextView *subject_field = (UITextView *)[self.view viewWithTag:103];
            [subject_field becomeFirstResponder];
            break;
        }
        case 103: {
            // From Subject to Body
            UITextView *body_field = (UITextView *)[self.view viewWithTag:101];
            [body_field becomeFirstResponder];
            break;
        }
    }
    
    return YES;
}

-(IBAction)openContactChooser:(id)selector {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    picker.peoplePickerDelegate = self;
    
//    [self presentModalViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:^(void) {}];
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    CFTypeRef prop = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(prop,  identifier);
    NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(prop, index);
    
    [self addEmailAddress:email];
    [self makeEmailFieldFirstResponder];

    CFRelease(prop);

    [self dismissViewControllerAnimated:YES completion:^(void){}];
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            // Select To:
            [[self.view viewWithTag:100] becomeFirstResponder];
            break;
        case 1:
            // Select From:
            [[self.view viewWithTag:102] becomeFirstResponder];
            break;
        case 2:
            // Select Subject:
            [[self.view viewWithTag:103] becomeFirstResponder];
            break;
        case 4:
            // Select content
            [[self.view viewWithTag:101] becomeFirstResponder];
            break;

        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // get the reference to the text field
 //   [textField setUserInteractionEnabled:YES];
   // [textField becomeFirstResponder];
}

-(void)makeEmailFieldFirstResponder {
    UITextField *textField = (UITextField *)[self.view viewWithTag:100];
    [textField becomeFirstResponder];
}

-(void)addEmailFromTextField {
    UITextField *textField = (UITextField *)[self.view viewWithTag:100];
    if (textField.text && ![textField.text isEqualToString:@""]) {
        [self addEmailAddress:textField.text];
        textField.text = @"";
    }
}

-(void)addEmailAddress: (NSString *)email {
    NSMutableString *tmp = [email mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)tmp);
    email = [tmp copy];

    if ([existing_emails objectForKey:email]) {
        return;
    }
    [existing_emails setObject:email forKey:email];
    [email_list addObject:email];

    [self setHasValidEmail];
    NSLog(@"Email list: %@", email_list);
    [self drawEmailAddresses];
}

-(void)removeEmailAddress: (NSString *)email {
    if (![existing_emails objectForKey:email]) {
        return;
    }
    
    [existing_emails removeObjectForKey:email];
    [email_list removeObject:email];

    [self setHasValidEmail];
    NSLog(@"Email list (post remove): %@", email_list);
}

-(void)setHasValidEmail {
    self.has_valid_to_email = FALSE;
    for (NSString *email in email_list) {
        if ([self isValidEmail:email]) {
            self.has_valid_to_email = TRUE;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (self.to_cell_size) {
            return self.to_cell_size;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];

}

-(void)drawEmailAddresses {
    UIView *new_container = [[UIView alloc] init];
    UIView *to_container = [self.view viewWithTag:800];

    CGFloat to_width = to_container.frame.size.width;
    CGFloat available_width = to_width - MARGIN_LEFT - MARGIN_RIGHT;

    float current_x = MARGIN_LEFT;
    float current_y = MARGIN_TOP;
    CGFloat last_height = 0.0;
    for (int i = 0; i < email_list.count; i++) {
        NSString *email = [email_list objectAtIndex:i];
        UILabel *email_label = [[UILabel alloc] init];
        
        NSString *email_with_formatting = [NSString stringWithFormat:@"%@, ", email];
        email_label.text = email_with_formatting;
        
        CGSize bound = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        CGRect frame_size = [email_with_formatting boundingRectWithSize:bound options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: email_label.font} context:nil];

        CGFloat width = frame_size.size.width;
        CGFloat height = frame_size.size.height;
        last_height = height;

        // Handle overflow...
        if ((width + current_x) > available_width) {
            current_x = MARGIN_LEFT;
            current_y = current_y + height;
        }
    
        if (width > to_width) {
            width = available_width;
        }
        
        if (![self isValidEmail:email]) {
            email_label.backgroundColor = [UIColor redColor];
            email_label.textColor = [UIColor whiteColor];
        }
        
        email_label.frame = CGRectMake(current_x, current_y, width, height);
        current_x += width;
        
        [new_container addSubview:email_label];
    }
    
    // Start by moving the text input field
    // If we're in the last ... 75% of the width, drop down
    UITextField *email_field = (UITextField *)[self.view viewWithTag:100];
    if (current_x > available_width * TEXT_FIELD_LIMIT) {
        current_x = MARGIN_LEFT;
        current_y = current_y + last_height;
    }

    // Have the textfield fill the available width
    CGFloat textfield_width = available_width - current_x;
    // The text input needs to be at a different Y value to offset it properly
    CGFloat textfield_y = current_y - TEXTFIELD_Y_INSET;
    email_field.frame = CGRectMake(current_x, textfield_y, textfield_width, email_field.frame.size.height);


    // Resize our table row...
    self.to_cell_size = current_y + email_field.frame.size.height;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

    // Replace the old list view with the new one
    UIView *existing_container = [to_container viewWithTag:900];
    if (existing_container) {
        [existing_container removeFromSuperview];
    }
    
    new_container.tag = 900;
    [to_container addSubview:new_container];
    
}

-(IBAction)sendEmail:(id)selector {
    if (self.is_sending_email) {
        return;
    }
    
    UITextView *email_field = (UITextView *)[self.view viewWithTag:100];
    UITextView *from_field = (UITextView *)[self.view viewWithTag:102];
    UITextView *subject_field = (UITextView *)[self.view viewWithTag:103];

    UITextView *content = (UITextView *)[self.view viewWithTag:101];
    
    NSString *from_value = [from_field text];
    
    [from_field resignFirstResponder];
    [subject_field resignFirstResponder];
    [email_field resignFirstResponder];
    [content resignFirstResponder];
    
    self.rest = [[REST alloc] init];
    self.rest.delegate = self;
    
    // Make it so we don't double send - the overlay doesn't cover the send button
    self.is_sending_email = TRUE;
    
    NSDictionary *data = @{@"to": [self email_list],
                                  @"comment": [content text],
                                  @"subject": [subject_field text],
                                  @"from": from_value
                                  };
    
    NSString *url = [NSString stringWithFormat:@"/api/v1/spot/%@/share", self.space.remote_id];
    
    if (!self.overlay) {
        self.overlay = [[OverlayMessage alloc] init];
        [self.overlay addTo:self.view];
    }
    [self.overlay showOverlay:@"Sending..." animateDisplay:YES afterShowBlock:^(void) {
        [self.rest putURL:url withBody:[data JSONRepresentation]];
    }];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self drawEmailAddresses];
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    NSLog(@"Body: %@", [request responseString]);
    [self.overlay showOverlay:@"Email sent!" animateDisplay:NO afterShowBlock:^(void) {}];
    [self.overlay setImage: [UIImage imageNamed:@"GreenCheckmark"]];

    [self.overlay hideOverlayAfterDelay:1.0 animateHide:YES afterHideBlock:^(void) {
        [self.navigationController popViewControllerAnimated:TRUE];
        self.is_sending_email = FALSE;
    }];
}

@end
