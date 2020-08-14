

#import "UIToolbar+Picker.h"
#import <objc/runtime.h>

static const int kCommomMarginX = 0;
static const int kPickerToolbarDelegateKey;

@implementation UIToolbar (Picker)

- (id<HsPickerToolbarDelegate>)pickerToolbarDelegate
{
    return objc_getAssociatedObject(self, &kPickerToolbarDelegateKey);
}

- (void)setPickerToolbarDelegate:(id<HsPickerToolbarDelegate>)pickerToolbarDelegate
{
    objc_setAssociatedObject(self, &kPickerToolbarDelegateKey, pickerToolbarDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (instancetype)initWithLeftTitles:(NSArray *)leftTitles
                       rightTitles:(NSArray *)rightTitles
                         leftColor:(UIColor *)leftColor
                        rightColor:(UIColor *)rightColor
{
    self = [super init];
    
    NSMutableArray *items = [NSMutableArray array];
    
    // left space
    UIBarButtonItem *leftSpace = [self barItemWithType:UIBarButtonSystemItemFixedSpace];
    leftSpace.width = kCommomMarginX;
    [items addObject:leftSpace];
    
    // left items
    for (NSInteger index = 0; index < leftTitles.count; ++index) {
        UIBarButtonItem *item = [self actionBarButtonItemWithTitle:leftTitles[index]];
        item.tag = index;
        [items addObject:item];
        
        if (leftColor) {
            item.tintColor = leftColor;
        }
    }
    
    // middle space
    UIBarButtonItem *middleSpace = [self barItemWithType:UIBarButtonSystemItemFlexibleSpace];
    [items addObject:middleSpace];
    
    // right items
    for (NSInteger index = 0; index < rightTitles.count; ++index) {
        UIBarButtonItem *item = [self actionBarButtonItemWithTitle:rightTitles[index]];
        item.tag = leftTitles.count + index;
        
        if (rightColor) {
            item.tintColor = rightColor;
        }
        [items addObject:item];
    }
    
    // right space
    UIBarButtonItem *rightSpace = [self barItemWithType:UIBarButtonSystemItemFixedSpace];
    rightSpace.width = kCommomMarginX;
    [items addObject:rightSpace];
    
    self.items = items;
    
    return self;
}

- (instancetype)initWithLeftTitles:(NSArray *)leftTitles
                       rightTitles:(NSArray *)rightTitles
{
    return [self initWithLeftTitles:leftTitles
                        rightTitles:rightTitles
                          leftColor:nil
                         rightColor:nil];
}

- (UIBarButtonItem *)barItemWithType:(UIBarButtonSystemItem)type
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:type
                                                         target:nil
                                                         action:nil];
}

- (UIBarButtonItem *)actionBarButtonItemWithTitle:(NSString *)title
{
    return [[UIBarButtonItem alloc] initWithTitle:title
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(itemAction:)];
}

- (void)itemAction:(UIBarButtonItem *)item
{
    if ([self.pickerToolbarDelegate respondsToSelector:@selector(toolbar:clickedItemAtIndex:)]) {
        [self.pickerToolbarDelegate toolbar:self clickedItemAtIndex:item.tag];
    }
}

@end
