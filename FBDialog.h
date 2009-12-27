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
 *
 * Modified by Christopher Long
*/

#import "FBConnect/FBConnectGlobal.h"

@protocol FBDialogDelegate;

@interface FBDialog : UIView {
  id<FBDialogDelegate> _delegate;
  NSURL* _loadingURL;
  UIWebView* _webView;
  UIActivityIndicatorView* _spinner;
  UIImageView* _iconView;
  UILabel* _titleLabel;
  UIButton* _closeButton;
  UIDeviceOrientation _orientation;
  BOOL _showingKeyboard;
}

/**
 * The delegate.
 */
@property(nonatomic,assign) id<FBDialogDelegate> delegate;

/**
 * The title that is shown in the header atop the view;
 */
@property(nonatomic,copy) NSString* title;

/**
 * Creates the view but does not display it.
 */
- (id)initWithSession:(FBSession*)session;

/**
 * Displays the view with an animation.
 *
 * The view will be added to the top of the current key window.
 */
- (void)show;

/**
 * Displays the first page of the dialog.
 *
 * Do not ever call this directly.  It is intended to be overriden by subclasses.
 */
- (void)load;

/**
 * Hides the view and notifies delegates of success or cancellation.
 */
- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated;

/**
 * Hides the view and notifies delegates of an error.
 */
- (void)dismissWithError:(NSError*)error animated:(BOOL)animated;

/**
 * Subclasses may override to perform actions just prior to showing the dialog.
 */
- (void)dialogWillAppear;

/**
 * Subclasses may override to perform actions just after the dialog is hidden.
 */
- (void)dialogWillDisappear;

/**
 * Subclasses should override to process data returned from the server in a 'fbconnect' url.
 *
 * Implementations must call dismissWithSuccess:YES at some point to hide the dialog.
 */
- (void)dialogDidSucceed:(NSURL*)url;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol FBDialogDelegate <NSObject>

@optional

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidSucceed:(FBDialog*)dialog;

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidCancel:(FBDialog*)dialog;

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error;

@end
