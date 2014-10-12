//
//  DGSlideViewController.m
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

#import <QuartzCore/QuartzCore.h>
#import "DGSlideViewController.h"

@interface DGSlideViewController ()

@end

@implementation DGSlideViewController
{
    UIViewController *_backViewController;
    UIViewController *_frontViewController;
    
    BOOL _isIos7OrLater;
    BOOL _isOpen, _isAnimating, _isDragging;
    
    UIView *_tapShieldView;
}

#pragma mark Initialization

- (void)DGSlideViewController_initialize
{
    _isIos7OrLater = [UIDevice.currentDevice.systemVersion compare:@"7.0" options:NSNumericSearch] >= NSOrderedSame;
    
    _isOpen = NO;
    _isAnimating = NO;
    _isDragging = NO;
    
    _openAnimationDuration = 0.1;
    _closeAnimationDuration = 0.3;
    _exposedWidth = 200.f;
    _exposedWidthRelative = 0.f;
    _frontScale = 0.8f;
    
    _frontShadowColor = UIColor.blackColor;
    _frontShadowOpacity = .8f;
    _frontShadowRadius = 10.f;
    _frontShadowOffset = CGSizeMake(-10.f, 0.f);
    
    _tapShieldView = [[UIView alloc] init];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [_tapShieldView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [panGesture setMaximumNumberOfTouches:2];
    
    [_tapShieldView addGestureRecognizer:panGesture];
}

- (id)init
{
    return [self initWithBackViewController:nil andFrontViewController:nil];
}

- (id)initWithBackViewController:(UIViewController *)backViewController
{
    return [self initWithBackViewController:backViewController andFrontViewController:nil];
}

- (id)initWithBackViewController:(UIViewController *)backViewController andFrontViewController:(UIViewController *)frontViewController
{
    self = [super init];
    if (self)
    {
        [self DGSlideViewController_initialize];
        
        _backViewController = backViewController;
        _frontViewController = frontViewController;
        
        if (_backViewController)
        {
            [self addChildViewController:_backViewController];
            [self.view addSubview:_backViewController.view];
            _backViewController.view.frame = self.view.bounds;
            [_backViewController didMoveToParentViewController:self];
        }
        
        if (_frontViewController)
        {
            [self addChildViewController:_backViewController];
            [self.view addSubview:_backViewController.view];
            _frontViewController.view.frame = self.view.bounds;
            [_backViewController didMoveToParentViewController:self];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self DGSlideViewController_initialize];
    }
    return self;
}

#pragma mark UIView lifecycle

- (void)viewDidLayoutSubviews
{
    CGRect bounds = self.view.bounds;
    
    _backViewController.view.frame = bounds;
    
    if (!_isDragging && !_isAnimating)
    {
        if (_isOpen)
        {
            [self applyOpenFrontPositionToView:_frontViewController.view];
        }
        else
        {
            [self applyClosedFrontPositionToView:_frontViewController.view];
    }
    }
}

#pragma mark Property accessors

- (UIViewController *)backViewController
{
    return _backViewController;
}

- (void)setBackViewController:(UIViewController *)backViewController
{
    [self setBackViewController:backViewController animated:NO];
}

- (void)setBackViewController:(UIViewController *)backViewController animated:(BOOL)animated
{
    if (animated)
    {
        CGFloat oldBackAlpha = _backViewController.view.alpha;
        CGFloat newBackAlpha = backViewController.view.alpha;
        
        UIViewController *oldViewController = _backViewController;
        [oldViewController willMoveToParentViewController:nil];
        
        _backViewController.view.frame = self.view.bounds;
        _backViewController.view.alpha = 0.f;
        
        _backViewController = backViewController;
        [self addChildViewController:_backViewController];
        [self.view insertSubview:_backViewController.view atIndex:0];
        
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            oldViewController.view.alpha = 0.f;
            backViewController.view.alpha = newBackAlpha;
            
        } completion:^(BOOL finished) {
            
            [oldViewController.view removeFromSuperview];
            [oldViewController removeFromParentViewController];
            oldViewController.view.alpha = oldBackAlpha;
            
            if (backViewController == _backViewController)
            {
                [backViewController didMoveToParentViewController:self];
            }
            
        }];
    }
    else
    {
        if (_backViewController)
        {
            [_backViewController willMoveToParentViewController:nil];
            [_backViewController.view removeFromSuperview];
            [_backViewController removeFromParentViewController];
        }
        
        _backViewController = backViewController;
        [self addChildViewController:_backViewController];
        [self.view insertSubview:_backViewController.view atIndex:0];
        _backViewController.view.frame = self.view.bounds;
        [_backViewController didMoveToParentViewController:self];
    }
}

- (UIViewController *)frontViewController
{
    return _frontViewController;
}

- (void)setFrontViewController:(UIViewController *)frontViewController
{
    [self setFrontViewController:frontViewController animated:NO];
}

- (void)setFrontViewController:(UIViewController *)frontViewController animated:(BOOL)animated
{
    if (animated)
    {
        UIViewController *oldFrontViewController = _frontViewController;
        
        if (oldFrontViewController && oldFrontViewController != frontViewController)
        {
            [oldFrontViewController willMoveToParentViewController:nil];
        }
        
        _isAnimating = YES;
        _isOpen = YES;
        
        [self setupShadowForView:oldFrontViewController.view];
        [self setupShadowForView:frontViewController.view];
        
        [UIView animateWithDuration:_closeAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self applyOpenOverFrontPositionToView:oldFrontViewController.view];
            
        } completion:^(BOOL finished) {
            
            if (oldFrontViewController == _frontViewController && oldFrontViewController != frontViewController)
            {
                [oldFrontViewController.view removeFromSuperview];
                [oldFrontViewController removeFromParentViewController];
                [self removeShadowForView:oldFrontViewController.view];
                [self removeShieldForView:oldFrontViewController.view];
            }
            
            _frontViewController = frontViewController;
            [self addChildViewController:frontViewController];
            [self.view addSubview:frontViewController.view];
            [self applyOpenOverFrontPositionToView:frontViewController.view];
            [self setupShadowForView:frontViewController.view];
            
            [UIView animateWithDuration:_closeAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [self applyClosedFrontPositionToView:frontViewController.view];
                
            } completion:^(BOOL finished) {
                
                _isOpen = NO;
                _isAnimating = NO;
                
                if (frontViewController == _frontViewController && oldFrontViewController != frontViewController)
                {
                    [frontViewController didMoveToParentViewController:self];
                    [self removeShadowForView:frontViewController.view];
                }
                
            }];
            
        }];
        
    }
    else
    {
        if (_frontViewController != frontViewController)
        {
            if (_frontViewController)
            {
                [_frontViewController willMoveToParentViewController:nil];
                [_frontViewController.view removeFromSuperview];
                [_frontViewController removeFromParentViewController];
                [self removeShadowForView:_frontViewController.view];
                [self removeShieldForView:_frontViewController.view];
            }
            
            _frontViewController = frontViewController;
            [self addChildViewController:_frontViewController];
            [self.view addSubview:_frontViewController.view];
            if (_isOpen)
            {
                [self applyOpenFrontPositionToView:_frontViewController.view];
            }
            else
            {
                [self applyClosedFrontPositionToView:_frontViewController.view];
            }
            [self setupShadowForView:_frontViewController.view];
            [_frontViewController didMoveToParentViewController:self];
        }
    }
}

- (BOOL)isOpen
{
    return _isOpen;
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

#pragma mark Position calculations

- (CGFloat)closePositionForBounds:(CGRect *)bounds
{
    return 0.f;
}

- (CGFloat)overOpenPositionForBounds:(CGRect *)bounds
{
    return _isOnTheRight ? -bounds->size.width : bounds->size.width;
}

- (CGFloat)openPositionForBounds:(CGRect *)bounds
{
    CGFloat revealedWidth = _exposedWidth;
    if (revealedWidth <= 0.f)
    {
        revealedWidth = _exposedWidthRelative * bounds->size.width;
    }
    return _isOnTheRight ? -revealedWidth : revealedWidth;
}

#pragma mark Applying front-view's positions

- (void)applyOpenFrontPositionToView:(UIView *)view
{
    BOOL hasTransforms = _frontScale != 1.f;
    CGRect bounds = self.view.bounds;
    
    if (hasTransforms)
    {
        view.transform = CGAffineTransformIdentity;
    }
    
    CGFloat openPosition = [self openPositionForBounds:&bounds];
    
    view.frame = CGRectMake(openPosition, 0, bounds.size.width, bounds.size.height);
    
    if (hasTransforms)
    {
        view.transform = CGAffineTransformMakeScale(_frontScale, _frontScale);
    }
}

- (void)applyOpenOverFrontPositionToView:(UIView *)view
{
    BOOL hasTransforms = _frontScale != 1.f;
    CGRect bounds = self.view.bounds;
    
    if (hasTransforms)
    {
        view.transform = CGAffineTransformIdentity;
    }
    
    view.frame = CGRectMake([self overOpenPositionForBounds:&bounds], 0, bounds.size.width, bounds.size.height);
    
    if (hasTransforms)
    {
        view.transform = CGAffineTransformMakeScale(_frontScale * 0.9f, _frontScale * 0.9f);
    }
}

- (void)applyClosedFrontPositionToView:(UIView *)view
{
    BOOL hasTransforms = _frontScale != 1.f;
    CGRect bounds = self.view.bounds;
    
    if (hasTransforms)
    {
        view.transform = CGAffineTransformIdentity;
    }
    
    view.frame = CGRectMake([self closePositionForBounds:&bounds], 0, bounds.size.width, bounds.size.height);
    
    if (hasTransforms)
    {
        view.transform = CGAffineTransformMakeScale(1.f, 1.f);
    }
}

#pragma mark Internal helpers

- (BOOL)isViewAtClosedPosition:(UIView *)view
{
    CGRect bounds = self.view.bounds;
    return view.frame.origin.x == bounds.origin.x;
}

- (BOOL)isViewAtOpenPosition:(UIView *)view
{
    CGRect bounds = self.view.bounds;
    return view.frame.origin.x == bounds.origin.x + bounds.size.width;
}

#pragma mark Gesture recognizer responders

- (void)tapGestureRecognized:(UIPanGestureRecognizer *)gesture
{
    [self toggleWithCompletion:nil];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture
{
    UIGestureRecognizerState state = gesture.state;
    UIView *panningView = gesture.view;
    UIView *movingView = _frontViewController.view;
    
    if (state == UIGestureRecognizerStateBegan)
    {
        _isDragging = YES;
        
        [self setupShadowForView:_frontViewController.view];
    }
    
    CGRect bounds = self.view.bounds;
    CGRect movingFrame = movingView.frame;
    
    if (state == UIGestureRecognizerStateBegan ||
        state == UIGestureRecognizerStateChanged ||
        state == UIGestureRecognizerStateEnded)
    {
        CGPoint translation = [gesture translationInView:panningView];
        
        CGFloat untransformedOriginX = movingFrame.origin.x - (movingView.bounds.size.width - movingFrame.size.width) * movingView.layer.anchorPoint.x;
        
        CGFloat closePosition = [self closePositionForBounds:&bounds];
        
        if ((_isOnTheRight && untransformedOriginX + translation.x > closePosition) ||
            (!_isOnTheRight && untransformedOriginX + translation.x < closePosition))
        {
            translation.x = closePosition;
        }
        
        movingFrame.origin.x += translation.x;
        movingView.frame = movingFrame;
        
        CGFloat openPosition = [self openPositionForBounds:&bounds];
        CGFloat openAmount = untransformedOriginX / (openPosition - closePosition);
        
        BOOL hasTransforms = _frontScale != 1.f;
        if (hasTransforms)
        {
            CGFloat scaleAmount = 1.f - (openAmount * (1.f - _frontScale));
            movingView.transform = CGAffineTransformMakeScale(scaleAmount, scaleAmount);
        }
        
        [gesture setTranslation:CGPointZero inView:[panningView superview]];
    }
    
    if (state == UIGestureRecognizerStateEnded)
    {
        CGSize size = bounds.size;
        
        CGFloat untransformedOriginX = movingFrame.origin.x - (movingView.bounds.size.width - movingFrame.size.width) * movingView.layer.anchorPoint.x;
        
        CGFloat velocity = [gesture velocityInView:panningView].x;
        
        BOOL shouldOpen = NO;
        
        if (velocity > 0.f)
        {
            shouldOpen = !_isOnTheRight;
        }
        else if (velocity < 0.f)
        {
            shouldOpen = _isOnTheRight;
        }
        else
        {
            shouldOpen = (_isOnTheRight && movingView.center.x < 0.f) ||
            (!_isOnTheRight && movingView.center.x > size.width);
        }
        
        CGFloat targetX = shouldOpen ? [self openPositionForBounds:&bounds] : [self closePositionForBounds:&bounds];
        CGFloat distanceToTravel = fabsf(targetX - untransformedOriginX);
        NSTimeInterval durationForTheRestOfTheAnimation = distanceToTravel == 0.f ? 0.0 : ( distanceToTravel / fabsf(velocity));
        NSTimeInterval maxDuration = shouldOpen ? _openAnimationDuration : _closeAnimationDuration;
        
        if (durationForTheRestOfTheAnimation > maxDuration)
        {
            durationForTheRestOfTheAnimation = maxDuration;
        }
        
        if (shouldOpen)
        {
            [self openWithDuration:durationForTheRestOfTheAnimation animationOptions:UIViewAnimationOptionCurveEaseOut completion:nil];
        }
        else
        {
            [self closeWithDuration:durationForTheRestOfTheAnimation animationOptions:UIViewAnimationOptionCurveEaseOut completion:nil];
        }
        
        _isDragging = NO;
    }
}

#pragma mark Opening/Closing helpers

- (void)openWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void(^)())completionBlock
{
    if (_isOpen && (!_frontViewController || [self isViewAtOpenPosition:_frontViewController.view]))
    {
        if (completionBlock)
        {
            completionBlock();
        }
        
        return;
    }
    
    _isOpen = YES;
    [self setupShadowForView:_frontViewController.view];
    
    void(^ animationsBlock)() = ^{
        
        _isAnimating = YES;
        [self applyOpenFrontPositionToView:_frontViewController.view];
        
    };
    
    void(^ animationsCompletionBlock)(BOOL finished) = ^(BOOL finished){
        
        _isAnimating = NO;
        
        // Shield the front view from taps inside, and instead catch all taps to slide it back
        [self setupShieldForView:_frontViewController.view];
        
        if (completionBlock)
        {
            completionBlock();
        }
        
    };
    
    if (duration <= 0.0)
    {
        animationsBlock();
        animationsCompletionBlock(YES);
    }
    else
    {
        [UIView animateWithDuration:duration delay:0.0 options:animationOptions animations:animationsBlock completion:animationsCompletionBlock];
    }
}

- (void)openWithCompletion:(void(^)())completionBlock
{
    [self openWithDuration:_openAnimationDuration animationOptions:UIViewAnimationOptionCurveEaseInOut completion:completionBlock];
}

- (void)closeWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void(^)())completionBlock
{
    if (!_isOpen && (!_frontViewController || [self isViewAtClosedPosition:_frontViewController.view]))
    {
        if (completionBlock)
        {
            completionBlock();
        }
        
        return;
    }
    
    _isOpen = NO;
    
    // Remove the tap shield
    [self removeShieldForView:_frontViewController.view];
    
    
    void(^ animationsBlock)() = ^{
        
        _isAnimating = YES;
        [self applyClosedFrontPositionToView:_frontViewController.view];
        
    };
    
    void(^ animationsCompletionBlock)(BOOL finished) = ^(BOOL finished){
        
        _isAnimating = NO;
        
        [self removeShadowForView:_frontViewController.view];
        
        if (completionBlock)
        {
            completionBlock();
        }
        
    };
    
    if (duration <= 0.0)
    {
        animationsBlock();
        animationsCompletionBlock(YES);
    }
    else
    {
        [UIView animateWithDuration:duration delay:0.0 options:animationOptions animations:animationsBlock completion:animationsCompletionBlock];
    }
}

- (void)closeWithCompletion:(void(^)())completionBlock
{
    [self closeWithDuration:_closeAnimationDuration animationOptions:UIViewAnimationOptionCurveEaseInOut completion:completionBlock];
}

- (void)toggleWithDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)animationOptions completion:(void(^)())completionBlock
{
    if (_isOpen)
    {
        [self closeWithDuration:duration animationOptions:animationOptions completion:completionBlock];
    }
    else
    {
        [self openWithDuration:duration animationOptions:animationOptions completion:completionBlock];
    }
}

- (void)toggleWithCompletion:(void(^)())completionBlock
{
    if (_isOpen)
    {
        [self closeWithCompletion:completionBlock];
    }
    else
    {
        [self openWithCompletion:completionBlock];
    }
}

#pragma mark Internal view helpers

- (void)setupShadowForView:(UIView *)view
{
    view.layer.shadowColor = _frontShadowColor.CGColor;
    view.layer.shadowOpacity = _frontShadowOpacity;
    view.layer.shadowOffset = _frontShadowOffset;
    view.layer.shadowRadius = _frontShadowRadius;
    view.layer.masksToBounds = NO;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
}

- (void)removeShadowForView:(UIView *)view
{
    view.layer.shadowRadius = 0.f;
    view.layer.masksToBounds = YES;
}

- (void)setupShieldForView:(UIView *)view
{
    if (_tapShieldView.superview != view)
    {
        [view addSubview:_tapShieldView];
    }
    _tapShieldView.frame = view.bounds;
}

- (void)removeShieldForView:(UIView *)view
{
    if (_tapShieldView.superview == view)
    {
        [_tapShieldView removeFromSuperview];
    }
}

@end
