//
//  DGSlideViewController.h
//  DGSlideViewController
//
//  Created by Daniel Cohen Gindi on 10/12/14.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/DGSlideViewController
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE. 
//  

#import <UIKit/UIKit.h>

@interface DGSlideViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIViewController *backViewController;
@property (nonatomic, strong) IBOutlet UIViewController *frontViewController;

@property (nonatomic, assign) UI_APPEARANCE_SELECTOR NSTimeInterval openAnimationDuration;
@property (nonatomic, assign) UI_APPEARANCE_SELECTOR NSTimeInterval closeAnimationDuration;
@property (nonatomic, assign) UI_APPEARANCE_SELECTOR CGFloat exposedWidth;
@property (nonatomic, assign) UI_APPEARANCE_SELECTOR CGFloat exposedWidthRelative;
@property (nonatomic, assign) UI_APPEARANCE_SELECTOR CGFloat frontScale;

@property (nonatomic, strong) UI_APPEARANCE_SELECTOR UIColor *frontShadowColor;
@property (nonatomic, assign) UI_APPEARANCE_SELECTOR CGFloat frontShadowOpacity;
@property (nonatomic, assign) UI_APPEARANCE_SELECTOR CGSize frontShadowOffset;
@property (nonatomic, assign) UI_APPEARANCE_SELECTOR CGFloat frontShadowRadius;

@property (nonatomic, assign) BOOL isOnTheRight;

@property (nonatomic, assign, readonly) BOOL isOpen;
@property (nonatomic, assign, readonly) BOOL isAnimating;

- (id)initWithBackViewController:(UIViewController *)backViewController;
- (id)initWithBackViewController:(UIViewController *)backViewController andFrontViewController:(UIViewController *)frontViewController;

- (void)setBackViewController:(UIViewController *)backViewController animated:(BOOL)animated;
- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated;

- (void)tapGestureRecognized:(UIPanGestureRecognizer *)gesture;
- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture;

- (void)openWithCompletion:(void(^)())completionBlock;

- (void)openWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void(^)())completionBlock;

- (void)closeWithCompletion:(void(^)())completionBlock;

- (void)closeWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void(^)())completionBlock;

- (void)toggleWithCompletion:(void(^)())completionBlock;

- (void)toggleWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void(^)())completionBlock;

@end
