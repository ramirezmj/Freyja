//
//  LoginViewController.m
//  Freyja
//
//  Created by Jose Manuel Ramirez Martinez on 17/11/14.
//  Copyright (c) 2014 Jose Manuel Ramírez Martínez. All rights reserved.
//

#import "LoginViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Constants.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityIndicator.hidden = YES;
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

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if ( !user ) {
            if ( !error ) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
        }
    }];
}

#pragma mark - Helper Methods

- (void)updateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if ( !error ) {
            NSDictionary *userDictionary = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];

//            Use this to log the response into the console.
//            NSLog(@"%@", result);
            
            if ( userDictionary[@"name"] ) {
                userProfile[KUserProfileNameKey] = userDictionary[@"name"];
            }
            if ( userDictionary[@"first_name"]  ) {
                userProfile[KUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if ( userDictionary[@"location"][@"name"] ) {
                userProfile[KUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if ( userDictionary[@"gender"] ) {
                userProfile[KUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if ( userDictionary[@"birthday"] ) {
                userProfile[KUserProfileBirthdayKey] = userDictionary[@"birthday"];
            }
            if ( userDictionary[@"interested_in"] ) {
                userProfile[KUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kUserProfileKey];
            [[PFUser currentUser] saveInBackground];
        }
        else {
            NSLog(@"Error in FB request %@", error);
        }
        
    }];
}

@end
