//
//  Bank.h
//  Remote
//
//  Created by Jason Cardwell on 9/13/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "ModelObject.h"

typedef NS_OPTIONS(uint8_t, BankFlags) {
    BankDefault    = 0b00000000,
    BankDetail     = 0b00000001,
    BankPreview    = 0b00000010,
    BankThumbnail  = 0b00000100,
    BankEditable   = 0b00001000,
    BankNoSections = 0b00010000,
    BankReserved   = 0b11100000
};

@protocol BankableDetailDelegate;

@protocol Bankable <NamedModelObject>

// Class info
+ (NSString *)directoryLabel;
+ (BankFlags)bankFlags;
+ (UIImage *)directoryIcon;
+ (Class<BankableDetailDelegate>)detailViewControllerClass;
+ (NSFetchedResultsController *)bankableItems;

- (void)updateItem;
- (void)resetItem;

// Object info
@property (nonatomic, copy)                          NSString     * name;
@property (nonatomic, copy)                          NSString     * category;
@property (nonatomic, readonly)                      UIImage      * thumbnail;
@property (nonatomic, readonly)                      UIImage      * preview;
@property (nonatomic, assign)                        BOOL           user;
@property (nonatomic, readonly, getter = isEditable) BOOL           editable;
@property (nonatomic, readonly)                      MSDictionary * subBankables;

@end

@protocol BankableViewController <NSObject>

@property (nonatomic, strong) Class<Bankable> itemClass;

@end

@protocol BankableDetailDelegate <BankableViewController>

@property (nonatomic, strong) id<Bankable> item;
- (void)editItem;

@end

@interface BankInfo : NSManagedObject <MSJSONExport>

@property (nonatomic, copy)   NSString * name;
@property (nonatomic, copy)   NSString * category;
@property (nonatomic, assign) BOOL       user;

@end

@interface Bank : MSSingletonController

+ (NSArray *)registeredClasses;
+ (UIViewController<BankableDetailDelegate> *)detailControllerForItem:(id<Bankable>)item;
+ (UIViewController<BankableDetailDelegate> *)editingControllerForItem:(id<Bankable>)item;

@end

