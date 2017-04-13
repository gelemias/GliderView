//
//  GVScrollView.m
//  GlideView
//
//  Created by GuillermoD on 8/3/16.
//  Copyright © 2017. All rights reserved.
//

#import "GVScrollView.h"

@interface GVScrollView() <UIScrollViewDelegate>

@property (nonatomic) NSUInteger offsetIndex;
@property (nonatomic) BOOL isOpen;

@end

#define kDefaultMargin 20

#define kAniDuration 0.3
#define kAniDelay 0.0
#define kAniDamping 0.7
#define kAniVelocity 0.6

@implementation GVScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeByDefault];
    }
    
    return self;
}

- (void)initializeByDefault {
    
    self.margin = kDefaultMargin;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    [self setBounces:NO];
    [self setDirectionalLockEnabled:YES];
    [self setScrollsToTop:NO];
    [self setPagingEnabled:NO];
    [self setContentInset:UIEdgeInsetsZero];
    [self setDecelerationRate:UIScrollViewDecelerationRateFast];
    
    [self setOrientationType:GVScrollViewOrientationRightToLeft];
}

#pragma mark - Public Methods

- (void)setContent:(UIView *)content {
    _content = content;

    if (!content && CGRectIsNull(content.frame)) {
        return;
    }
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *container = [UIView new];

    [container addSubview:_content];
    [self addSubview:container];

    container.translatesAutoresizingMaskIntoConstraints = NO;
    _content.translatesAutoresizingMaskIntoConstraints = NO;

    if (self.orientationType == GVScrollViewOrientationRightToLeft) {
                
        [container addConstraints:@[[NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                    toItem:container   attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                                    toItem:container   attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]]];
        
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]]];
        if (CGRectIsEmpty(_content.frame)) {
            [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                   toItem:self     attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                   toItem:self           attribute:NSLayoutAttributeWidth multiplier:2.0 constant:0.0]]];
        } else {
            [container addConstraint:[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil      attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(_content.frame)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                toItem:self           attribute:NSLayoutAttributeWidth multiplier:1.0 constant:CGRectGetWidth(_content.frame)]];
        }
    }
    else if (self.orientationType == GVScrollViewOrientationLeftToRight) {
        
        [container addConstraints:@[[NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                    toItem:container   attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                                    toItem:container   attribute:NSLayoutAttributeLeading multiplier:1.0 constant:[self margin]]]];
        
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]]];
        if (CGRectIsEmpty(_content.frame)) {
            [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                   toItem:self     attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                   toItem:self           attribute:NSLayoutAttributeWidth multiplier:2.0 constant:0.0]]];
        } else {
            [container addConstraint:[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil      attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(_content.frame)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                toItem:self           attribute:NSLayoutAttributeWidth multiplier:1.0 constant:CGRectGetWidth(_content.frame)]];
        }
    }
    else if (self.orientationType == GVScrollViewOrientationBottomToTop) {
        
        [container addConstraints:@[[NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]]];

        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]]];
        
        if (CGRectIsEmpty(_content.frame)) {
            [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                   toItem:self     attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                   toItem:self      attribute:NSLayoutAttributeHeight multiplier:2.0 constant:0.0]]];
        } else {
            [container addConstraint:[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil      attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetHeight(_content.frame)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                toItem:self      attribute:NSLayoutAttributeHeight multiplier:1.0 constant:CGRectGetHeight(_content.frame)]];
        }
    }
    else if (self.orientationType == GVScrollViewOrientationTopToBottom) {
        
        [container addConstraints:@[[NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0],
                                    [NSLayoutConstraint constraintWithItem:_content  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                    toItem:container attribute:NSLayoutAttributeTop multiplier:1.0 constant:[self margin]]]];
        
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                               toItem:self      attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]]];
        
        if (CGRectIsEmpty(_content.frame)) {
            [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                   toItem:self     attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0],
                                   [NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                   toItem:self      attribute:NSLayoutAttributeHeight multiplier:2.0 constant:0.0]]];
        } else {
            [container addConstraint:[NSLayoutConstraint constraintWithItem:_content attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil      attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetHeight(_content.frame)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                toItem:self      attribute:NSLayoutAttributeHeight multiplier:1.0 constant:CGRectGetHeight(_content.frame)]];
        }
    }
    
    [self layoutIfNeeded];
    [self recalculateContentSize];
}

- (void)setOffsets:(NSArray<NSNumber *> *)offsets {
    NSMutableArray *reversedOffsets = [NSMutableArray new];
    for (NSNumber *number in offsets) {
        if ([number floatValue] > 1.0) {
            [NSException raise:@"Invalid offset value" format:@"offset represents a %% of contentView to be shown i.e. 0.5 of a contentView of 100px will show 50px"];
        }
        else if (self.orientationType == GVScrollViewOrientationTopToBottom ||
                 self.orientationType == GVScrollViewOrientationLeftToRight) {
            [reversedOffsets addObject:@(1 - number.floatValue)];
        }
    }
    
    NSArray *newOffsets = [offsets sortedArrayUsingSelector: @selector(compare:)];
    
    if (reversedOffsets.count > 0) {
        newOffsets = [reversedOffsets sortedArrayUsingSelector: @selector(compare:)];
        newOffsets = [[newOffsets reverseObjectEnumerator] allObjects];
    }
    
    if (newOffsets && ![_offsets isEqualToArray:newOffsets]) {
        [self recalculateContentSize];
    }
    _offsets = newOffsets;

}

- (void)expandWithCompletion:(void (^)(BOOL finished))completion {
    NSUInteger nextIndex = (self.offsetIndex + 1 < [[self offsets] count]) ? self.offsetIndex + 1 : self.offsetIndex;
    [self changeOffsetTo:nextIndex animated:NO completion:completion];
}

- (void)collapseWithCompletion:(void (^)(BOOL finished))completion {

    NSUInteger nextIndex = self.offsetIndex - 1;
    [self changeOffsetTo:nextIndex animated:NO completion:completion];
}

- (void)closeWithCompletion:(void (^)(BOOL finished))completion {
    [self changeOffsetTo:0 animated:NO completion:completion];
}

- (void)changeOffsetTo:(NSUInteger)offsetIndex animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    self.panGestureRecognizer.enabled = NO;
    [UIView animateWithDuration:kAniDuration delay:kAniDelay usingSpringWithDamping:kAniDamping
          initialSpringVelocity:kAniVelocity options:UIViewAnimationOptionCurveEaseOut animations:^{
              
              if (self.orientationType == GVScrollViewOrientationLeftToRight) {
                  CGFloat margin = (offsetIndex == 0 || offsetIndex == self.offsets.count - 1) ? self.margin : 0;
                  [self setContentOffset:CGPointMake(([[self offsets] objectAtIndex:offsetIndex].floatValue * CGRectGetWidth(self.content.frame)) + margin, self.contentOffset.y) animated:animated];
              }
              else if (self.orientationType == GVScrollViewOrientationRightToLeft) {
                  [self setContentOffset:CGPointMake([[self offsets] objectAtIndex:offsetIndex].floatValue * CGRectGetWidth(self.content.frame), self.contentOffset.y) animated:animated];
              }
              else if (self.orientationType == GVScrollViewOrientationBottomToTop) {
                  [self setContentOffset:CGPointMake(self.contentOffset.x, [[self offsets] objectAtIndex:offsetIndex].floatValue * CGRectGetHeight(self.content.frame)) animated:animated];
              }
              else if (self.orientationType == GVScrollViewOrientationTopToBottom) {
                  CGFloat margin = (offsetIndex == 0 || offsetIndex == self.offsets.count - 1) ? self.margin : 0;
                  [self setContentOffset:CGPointMake(self.contentOffset.x, ([[self offsets] objectAtIndex:offsetIndex].floatValue * CGRectGetHeight(self.content.frame)) + margin) animated:animated];
              }
          } completion:^(BOOL finished) {
              self.offsetIndex = offsetIndex;
              self.isOpen = (self.offsetIndex == 0) ? NO : YES;
              
              self.panGestureRecognizer.enabled = YES;
              
              if (completion) {
                  completion(finished);
              }
          }];
}

#pragma mark - Private methods

- (void)recalculateContentSize {
    
    CGSize size = self.contentSize;
    
    if (self.orientationType == GVScrollViewOrientationBottomToTop) {
        size.height = CGRectGetHeight(self.frame) + (CGRectGetHeight(self.content.frame) * [self.offsets lastObject].floatValue) + self.margin;
    }
    else if (self.orientationType == GVScrollViewOrientationTopToBottom){
        size.height = CGRectGetHeight(self.frame) + (CGRectGetHeight(self.content.frame) * [self.offsets firstObject].floatValue) + self.margin;
    }
    else if (self.orientationType == GVScrollViewOrientationRightToLeft) {
        size.width = CGRectGetWidth(self.frame) + (CGRectGetWidth(self.content.frame) * [self.offsets lastObject].floatValue) + self.margin;
    }
    else if (self.orientationType == GVScrollViewOrientationLeftToRight) {
        size.width = CGRectGetWidth(self.frame) + (CGRectGetWidth(self.content.frame) * [self.offsets firstObject].floatValue) + self.margin;
    }

    [self setContentSize:size];
    [self layoutIfNeeded];
}

#pragma mark - touch handler

- (BOOL)viewContainsPoint:(CGPoint)point inView:(UIView *)content {
    if (CGRectContainsPoint(_content.frame, point)) {
        return YES;
    }

    if (self.selectContentSubViews) {
        for (UIView *subView in content.subviews) {
            if (CGRectContainsPoint(subView.frame, point)) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    
    if (_content && [self viewContainsPoint:point inView:_content]) {
        
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            
            CGPoint pt = CGPointMake(fabs(point.x), fabs(point.y));

            CGPoint convertedPoint = [subview convertPoint:pt fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            
            if (hitTestView) {
                return hitTestView;
            }
        }
    }
    
    return nil;
}

@end
