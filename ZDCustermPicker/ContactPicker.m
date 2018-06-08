//
//  ContactPicker.m
//  CollectionTest
//
//  Created by apple on 2018/1/2.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import "ContactPicker.h"

@implementation ContactPicker

-(instancetype)initJumpVC:(UIViewController *)jumpVC CompletionHandler:(NameAndPhoneBlock)completionHandler{
    self = [super init];
    if (self) {
        self.jumpVC = jumpVC;
        self.resultBlock = [completionHandler copy];
    }
    return self;
}


-(void)showPicker{
    if (@available (iOS 9.0,*)) {
        CNContactPickerViewController *picker = [[CNContactPickerViewController alloc]init];
        picker.delegate = self;
        picker.displayedPropertyKeys = [NSArray arrayWithObject:CNContactPhoneNumbersKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_jumpVC presentViewController:picker animated:YES completion:NULL];
        });
    }else{
        ABPeoplePickerNavigationController *vc = [[ABPeoplePickerNavigationController alloc]init];
        vc.peoplePickerDelegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_jumpVC presentViewController:vc animated:YES completion:NULL];
        });
    }
}

#pragma mark -ABPersonViewControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_AVAILABLE_IOS(8_0){
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    //电话号码
    CFStringRef telValue = ABMultiValueCopyValueAtIndex(valuesRef,index);
    NSString *str = [NSString stringWithFormat:@"%@",telValue];
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    //姓名
    CFStringRef anFullName = ABRecordCopyCompositeName(person);
    NSString *nameStr = [NSString stringWithFormat:@"%@",anFullName];
    [_jumpVC dismissViewControllerAnimated:YES completion:^{
        self.resultBlock(nameStr?:@"",str?:@"");
        
    }];
}

#pragma mark -CNContactPickerDelegate
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{
    CNContact *person = contactProperty.contact;
    NSString *firstName = person.givenName;
    NSString *lastName = person.familyName;
    CNPhoneNumber *phoneNumber = contactProperty.value;
    NSString *phoneValue = phoneNumber.stringValue;
    phoneValue = [phoneValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *nameStr = [NSString stringWithFormat:@"%@%@",lastName,firstName];
    self.resultBlock(nameStr?:@"",phoneValue?:@"");
}

@end
