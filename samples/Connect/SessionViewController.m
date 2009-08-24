/*
 * Copyright 2009 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#import "SessionViewController.h"
#import "FBConnect/FBConnect.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// This application will not work until you enter your Facebook application's API key here:

static NSString* kApiKey = @"<YOUR API KEY>";

// Enter either your API secret or a callback URL (as described in documentation):
static NSString* kApiSecret = nil; // @"<YOUR SECRET KEY>";
static NSString* kGetSessionProxy = nil; // @"<YOUR SESSION CALLBACK)>";

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SessionViewController

@synthesize label = _label;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:@"SessionViewController" bundle:nibBundleOrNil]) {
    if (kGetSessionProxy) {
      _session = [[FBSession sessionForApplication:kApiKey getSessionProxy:kGetSessionProxy
                             delegate:self] retain];
    } else {
      _session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
    }
  }
  return self;
}

- (void)dealloc {
  [_session release];
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewDidLoad {
  [_session resume];
  _loginButton.style = FBLoginButtonStyleWide;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
  _label.text = [NSString stringWithFormat:@"Error(%d) %@", error.code,
    error.localizedDescription];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBSessionDelegate

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
  _permissionButton.hidden = NO;
  _feedButton.hidden = NO;

  NSString* fql = [NSString stringWithFormat:
    @"select uid,name from user where uid == %lld", session.uid];

  NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
  [[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

- (void)sessionDidLogout:(FBSession*)session {
  _label.text = @"";
  _permissionButton.hidden = YES;
  _feedButton.hidden = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

- (void)request:(FBRequest*)request didLoad:(id)result {
  NSArray* users = result;
  NSDictionary* user = [users objectAtIndex:0];
  NSString* name = [user objectForKey:@"name"];
  _label.text = [NSString stringWithFormat:@"Logged in as %@", name];
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
  _label.text = [NSString stringWithFormat:@"Error(%d) %@", error.code,
    error.localizedDescription];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)askPermission:(id)target {
  FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
  dialog.delegate = self;
  dialog.permission = @"status_update";
  [dialog show];
}

- (void)publishFeed:(id)target {
  FBFeedDialog* dialog = [[[FBFeedDialog alloc] init] autorelease];
  dialog.delegate = self;
  dialog.templateBundleId = 9999999;
  dialog.templateData = @"{\"key1\": \"value1\"}";
  [dialog show];
}

@end
