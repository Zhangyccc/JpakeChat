//
//  JSQMessagesTypingIndicatorFooterView.h
//  JpakeChatApp
//
//  Created by Yuchi Zhang on 2017/7/24.
//  Copyright © 2017年 newcastle university. All rights reserved.
//

//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2014 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "JSQMessagesBubbleImageFactory.h"
/**
 *  A constant defining the default height of a `JSQMessagesTypingIndicatorFooterView`.
 */
FOUNDATION_EXPORT const CGFloat kJSQMessagesTypingIndicatorFooterViewHeight;

/**
 *  The `JSQMessagesTypingIndicatorFooterView` class implements a reusable view that can be placed
 *  at the bottom of a `JSQMessagesCollectionView`. This view represents a typing indicator
 *  for incoming messages.
 */
@interface JSQMessagesTypingIndicatorFooterView : UICollectionReusableView
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
#pragma mark - Class methods

/**
 *  Returns the `UINib` object initialized for the collection reusable view.
 *
 *  @return The initialized `UINib` object or `nil` if there were errors during
 *  initialization or the nib file could not be located.
 */
+ (UINib *)nib;

/**
 *  Returns the default string used to identify the reusable footer view.
 *
 *  @return The string used to identify the reusable footer view.
 */
+ (NSString *)footerReuseIdentifier;

#pragma mark - Typing indicator

/**
 *  Configures the receiver with the specified parameters.
 *  Call this method after dequeuing the footer view.
 *
 *  @param isIncoming     Specifies whether the typing indicator should be displayed
 *                        for an incoming message or outgoing message.
 *  @param indicatorColor The color of the typing indicator ellipsis.
 *  @param bubbleColor    The color of the message bubble.
 *  @param collectionView The collection view in which the footer view will appear.
 */
- (void)configureForIncoming:(BOOL)isIncoming
              indicatorColor:(UIColor *)indicatorColor
                 bubbleColor:(UIColor *)bubbleColor
              collectionView:(UICollectionView *)collectionView;

@end