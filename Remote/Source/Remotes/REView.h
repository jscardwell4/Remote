//
// REView.h
//
//
// Created by Jason Cardwell on 10/13/12.
//
//

#import "RemoteElement.h"

typedef NS_OPTIONS (NSUInteger, EditingStyle) {
    EditingStyleNotEditing   = 0 << 0,
    EditingStyleSelected     = 1 << 0,
    EditingStyleFocus        = 1 << 1,
    EditingStyleMoving       = 1 << 2
};

@interface REView : UIView

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initializers
////////////////////////////////////////////////////////////////////////////////

+ (REView *)viewWithModel:(RemoteElement *)model;
- (id)initWithModel:(RemoteElement *)model;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Relationships
////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong, readonly)  RemoteElement     * model;
@property (nonatomic, strong, readonly)  NSArray           * subelementViews;
@property (nonatomic, weak)              REView            * parentElementView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Syncing Model and View
////////////////////////////////////////////////////////////////////////////////

- (void) updateSubelementOrderFromView;
- (REView *)objectAtIndexedSubscript:(NSUInteger)idx;
- (REView *)objectForKeyedSubscript:(NSString *)key;

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
               toSibling:(REView *)siblingView
               attribute:(NSLayoutAttribute)attribute;

- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(REView *)siblingView
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

@interface REView (RemoteElementProperties)
// model backed properties

@property (nonatomic, assign)           int16_t                            tag;
@property (nonatomic, copy)             NSString                         * key;
@property (nonatomic, copy)             NSString                         * uuid;
@property (nonatomic, copy)             NSString                         * displayName;
@property (nonatomic, assign)           CGFloat                            backgroundImageAlpha;
@property (nonatomic, strong)           UIColor                          * backgroundColor;
@property (nonatomic, strong)           REImage                          * backgroundImage;
@property (nonatomic, strong)           RERemoteController               * controller;
@property (nonatomic, strong)           RemoteElement                    * parentElement;
@property (nonatomic, strong)           NSOrderedSet                     * subelements;
@property (nonatomic, strong, readonly) RELayoutConfiguration            * layoutConfiguration;

@property (nonatomic, assign)       BOOL                   proportionLock;
@property (nonatomic, assign)       REShape     shape;
@property (nonatomic, assign)       REStyle     style;
@property (nonatomic, readonly)     REType      type;
@property (nonatomic, readonly)     RESubtype   subtype;
@property (nonatomic, assign)       REOptions   options;
@property (nonatomic, readonly)     REState     state;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Debugging
////////////////////////////////////////////////////////////////////////////////

@interface REView (Debugging)

- (NSString *)framesDescription;
- (NSString *)constraintsDescription;
- (NSString *)viewConstraintsDescription;
- (NSString *)modelConstraintsDescription;

@end

NSString * prettyRemoteElementConstraint(NSLayoutConstraint * constraint);

MSKIT_STATIC_INLINE NSDictionary *viewFramesByIdentifier(REView * remoteElementView)
{
    NSMutableDictionary * viewFrames =
        [NSMutableDictionary dictionaryWithObjects:[remoteElementView.subelementViews
                                                    valueForKeyPath:@"frame"]
                                           forKeys:[remoteElementView.subelementViews
                  valueForKeyPath:@"uuid"]];

    viewFrames[remoteElementView.uuid] = NSValueWithCGRect(remoteElementView.frame);

    if (remoteElementView.parentElementView)
        viewFrames[remoteElementView.parentElementView.uuid] =
            NSValueWithCGRect(remoteElementView.parentElementView.frame);

    return viewFrames;
}
