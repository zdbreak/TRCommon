//
//  ContactPicker.h
//  CollectionTest
//
//  Created by apple on 2018/1/2.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

typedef void(^NameAndPhoneBlock)(NSString *name,NSString *phone);

@interface ContactPicker : NSObject <CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) UIViewController *jumpVC;

@property (copy, nonatomic) NameAndPhoneBlock resultBlock;

- (instancetype)initJumpVC:(UIViewController *)jumpVC CompletionHandler:(NameAndPhoneBlock)completionHandler;

- (void)showPicker;


@end
