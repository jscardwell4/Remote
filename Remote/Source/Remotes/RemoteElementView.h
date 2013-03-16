//
// RemoteElementView.h
//
//
// Created by Jason Cardwell on 10/13/12.
//
//

#import "RemoteElement.h"

typedef NS_OPTIONS (NSUInteger, EditingStyle) {
    EditingStyleNotEditing   = 0 << 0,
        EditingStyleSelected = 1 << 0,
        EditingStyleFocus    = 1 << 1,
        EditingStyleMoving   = 1 << 2
};

@interface RemoteElementView : UIView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (RemoteElementView *)remoteElementViewWithElement:(RemoteElement *)element;
- (id)initWithRemoteElement:(RemoteElement *)element;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Relationships
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong)            RemoteElement     * remoteElement;
@property (nonatomic, strong, readonly)  NSArray           * subelementViews;
@property (nonatomic, weak)              RemoteElementView * parentElementView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Syncing Model and View
////////////////////////////////////////////////////////////////////////////////

- (void) updateSubelementOrderFromView;
//- (RemoteElementView *)subelementViewForIdentifier:(NSString *)identifier;
- (RemoteElementView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (RemoteElementView *)objectForKeyedSubscript:(NSString *)key;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Editing
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, assign)                            EditingMode     editingMode;
@property (nonatomic, readonly, getter = isEditing)      BOOL            editing;
@property (nonatomic, assign)                            EditingStyle    editingStyle;
@property (nonatomic, getter = isResizable)              BOOL            resizable;
@property (nonatomic, getter = isMoveable)               BOOL            moveable;
@property (nonatomic, assign, getter = shouldShrinkwrap) BOOL            shrinkwrap;

- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation;
- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale;
- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute;
- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute;
- (void)willResizeViews:(NSSet *)views;
- (void)didResizeViews:(NSSet *)views;
- (void)willScaleViews:(NSSet *)views;
- (void)scale:(CGFloat)scale;
- (void)didScaleViews:(NSSet *)views;
- (void)willAlignViews:(NSSet *)views;
- (void)didAlignViews:(NSSet *)views;
- (void)willMoveViews:(NSSet *)views;
- (void)didMoveViews:(NSSet *)views;

@property (nonatomic, readonly) CGSize   minimumSize;
@property (nonatomic, readonly) CGSize   maximumSize;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties forwarded to model
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementView (RemoteElementProperties)
// model backed properties
@property (nonatomic, assign)           int16_t                            tag;
@property (nonatomic, copy)             NSString                         * key;
@property (nonatomic, copy)             NSString                         * identifier;
@property (nonatomic, copy)             NSString                         * displayName;
@property (nonatomic, assign)           CGFloat                            backgroundImageAlpha;
@property (nonatomic, strong)           UIColor                          * backgroundColor;
@property (nonatomic, strong)           GalleryImage                     * backgroundImage;
@property (nonatomic, strong)           RemoteController                 * controller;
@property (nonatomic, strong)           RemoteElement                    * parentElement;
@property (nonatomic, strong)           NSOrderedSet                     * subelements;
@property (nonatomic, strong, readonly) RemoteElementLayoutConfiguration * layoutConfiguration;

@property (nonatomic, assign)       BOOL                   proportionLock;
@property (nonatomic, assign)       RemoteElementShape     shape;
@property (nonatomic, assign)       RemoteElementStyle     style;
@property (nonatomic, readonly)     RemoteElementType      type;
@property (nonatomic, readonly)     RemoteElementSubtype   subtype;
@property (nonatomic, assign)       RemoteElementOptions   options;
@property (nonatomic, readonly)     RemoteElementState     state;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Debugging
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementView (Debugging)
- (NSString *)framesDescription;
- (NSString *)constraintsDescription;
- (NSString *)viewConstraintsDescription;
- (NSString *)modelConstraintsDescription;
@end

NSString * prettyRemoteElementConstraint(NSLayoutConstraint * constraint);

MSKIT_STATIC_INLINE NSDictionary * viewFramesByIdentifier(RemoteElementView * remoteElementView) {
    NSMutableDictionary * viewFrames =
        [NSMutableDictionary dictionaryWithObjects:[remoteElementView.subelementViews
                                                    valueForKeyPath:@"frame"]
                                           forKeys:[remoteElementView.subelementViews
                                                    valueForKeyPath:@"identifier"]];
    viewFrames[remoteElementView.identifier] = NSValueWithCGRect(remoteElementView.frame);
    if (remoteElementView.parentElementView)
        viewFrames[remoteElementView.parentElementView.identifier] =
            NSValueWithCGRect(remoteElementView.parentElementView.frame);
    return viewFrames;
}
