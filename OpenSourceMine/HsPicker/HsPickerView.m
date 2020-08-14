

#import "HsPickerView.h"

#ifdef DEBUG
//#define PICKER_DEBUG
#endif

#define HsPickerViewDeafultHeight  44

@interface HsPickerView() <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSArray *componentsInfo;

@end

@implementation HsPickerView

#pragma mark - lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self commonInit];
#ifdef PICKER_DEBUG
    self.picker.backgroundColor = [UIColor lightGrayColor];
#endif
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    CGRect frame = CGRectMake(0, 0, size.width, self.pickerViewHeight);
    frame.origin.x = (size.width - frame.size.width) / 2;
    frame.origin.y = (size.height - frame.size.height) / 2;
    self.picker.frame = frame;
}

#pragma mark - public

- (void)selectItem:(HsPickerItem *)item inComponent:(NSInteger)component animated:(BOOL)animated
{
    NSArray *componentsData = [self componentsDataArray:component];
    for (NSInteger row = 0; row < componentsData.count; ++row) {
        if ([item isEqualToItem:componentsData[row]]) {
            [self.picker selectRow:row inComponent:component animated:animated];
            [self selectedRowChangedInComponent:component];
            break;
        }
    }
}

- (HsPickerItem *)selectedItemInComponent:(NSInteger)component
{
    NSInteger row = [self.picker selectedRowInComponent:component];
    return [self itemForRow:row forComponent:component];
}

- (NSInteger)numberOfComponents
{
    return self.componentsInfo.count;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if ([self.pickerViewDelegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)]) {
        return [self.pickerViewDelegate pickerView:self rowHeightForComponent:component];
    }
    return HsPickerViewDeafultHeight;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self numberOfComponents];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
     HsPickerItem *obj = [self itemForRow:row forComponent:component];
    if ([self.pickerViewDelegate respondsToSelector:@selector(pickerView:viewForItem:)]) {
        return [self.pickerViewDelegate pickerView:self viewForItem:obj];
    }
    
    NSInteger labelTag = 99999;
    if (!view) {
        view = [[UIView alloc] init];
    }
    UILabel *label = [view viewWithTag:labelTag];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = self.pickerTextFont;
        label.textColor = self.pickerTextColor;
        label.backgroundColor = [UIColor clearColor];
        label.tag = labelTag;
        if (self.adjustTitleSizeToFitWidth) {
            [label adjustsFontSizeToFitWidth];
            label.numberOfLines = 0;
        }
        [view addSubview:label];
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];

    return view;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *componentsData = [self componentsDataArray:component];
    return componentsData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    HsPickerItem *item = [self itemForRow:row forComponent:component];
    return item.value;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    HsPickerItem *obj = [self itemForRow:row forComponent:component];
    if ([self.pickerViewDelegate respondsToSelector:@selector(pickerView:didSelectItem:inComponent:)]) {
        [self.pickerViewDelegate pickerView:self didSelectItem:obj inComponent:component];
    }
    
    [self selectedRowChangedInComponent:component];
}

#pragma mark - private

- (void)selectedRowChangedInComponent:(NSInteger)component
{
    if (0 <= component && component < self.componentsInfo.count) {
        id data = self.componentsInfo[component];
        if ([data isKindOfClass:HsPickerItem.class]) {
            HsPickerItem *item = (HsPickerItem *)data;
            for (NSInteger idx = 1; idx < item.level; ++idx) {
                [self safeReloadComponent:component + idx];
            }
        } else if ([data isKindOfClass:NSNumber.class]) {
            NSInteger parentComponent = [data integerValue];
            if (0 <= parentComponent && parentComponent < self.componentsInfo.count) {
                HsPickerItem *item = self.componentsInfo[parentComponent];
                if ([item isKindOfClass:HsPickerItem.class]) {
                    NSInteger level = item.level + parentComponent - component;
                    for (NSInteger idx = 1; idx < level; ++idx) {
                        [self safeReloadComponent:component + idx];
                    }
                }
            }
        }
    }
}

- (void)commonInit
{
    [self.picker removeFromSuperview];
    self.picker = [[UIPickerView alloc] initWithFrame:self.bounds];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self addSubview:self.picker];
    
    _pickerViewHeight = self.picker.bounds.size.height;
    self.pickerTextColor = [UIColor blackColor];
    self.pickerTextFont = [UIFont systemFontOfSize:16];
}

- (void)safeReloadComponent:(NSInteger)component
{
    if (0 <= component && component < self.componentsInfo.count) {
        if ([self.picker numberOfRowsInComponent:component]) {
            [self.picker selectRow:0 inComponent:component animated:NO];
        }
        [self.picker reloadComponent:component];
    }
}

- (NSArray *)componentsDataArray:(NSInteger)component
{
    if (component < 0 || component >= self.componentsInfo.count) {
        return nil;
    }
    
    id data = self.componentsInfo[component];
    if ([data isKindOfClass:NSArray.class]) {
        return data;
    }
    if ([data isKindOfClass:HsPickerItem.class]) {
        HsPickerItem *item = (HsPickerItem *)data;
        return item.subItems;
    }
    
    if ([data isKindOfClass:NSNumber.class]) {
        NSInteger parentComponent = [data integerValue];
        NSArray *ret = nil;
        while (parentComponent < component) {
            ret = [self componentsDataArray:parentComponent];
            if (parentComponent < 0 || parentComponent >= self.componentsInfo.count) {
                ret = nil;
                break;
            }
            NSInteger row = [self.picker selectedRowInComponent:parentComponent];
            if (row < 0 || row >= ret.count) {
                ret = nil;
                break;
            }
            HsPickerItem *item = ret[row];
            if (![item isKindOfClass:HsPickerItem.class]) {
                ret = nil;
                break;
            }
            ret = item.subItems;
            ++parentComponent;
        }
        return ret;
    }
    
    return nil;
}

- (HsPickerItem *)itemForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *componentsDataArray = [self componentsDataArray:component];
    if (0 <= row && row < componentsDataArray.count) {
        return componentsDataArray[row];
    }
    return nil;
}

- (void)reloadWithData:(NSArray *)data
{
    // check
    if (![self checkData:data]) {
        data = nil;
        NSAssert(0, @"data格式错误");
    }
    
    NSMutableArray *componentsInfo = [NSMutableArray array];
    for (id object in data) {
        if ([object isKindOfClass:NSArray.class]) {
            NSArray *array = (NSArray *)object;
            if (array.count) {
                [componentsInfo addObject:object];
            }
        } else if ([object isKindOfClass:HsPickerItem.class]) {
            HsPickerItem *item = (HsPickerItem *)object;
            [componentsInfo addObject:item];
            NSInteger level = item.level - 1;
            NSInteger index = componentsInfo.count - 1;
            while (--level >= 0) {
                [componentsInfo addObject:@(index)];
            }
        }
    }
    
    self.componentsInfo = componentsInfo;
    [self.picker reloadAllComponents];
}

- (BOOL)checkData:(NSArray *)data
{
    if (data && ![data isKindOfClass:NSArray.class]) {
        return NO;
    }
    for (id object in data) {
        if ([object isKindOfClass:NSArray.class]) {
            for (HsPickerItem *item in object) {
                if (![self checkItem:item]) {
                    return NO;
                }
            }
        } else {
            if (![self checkItem:object]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)checkItem:(HsPickerItem *)item
{
    if (![item isKindOfClass:HsPickerItem.class]) {
        return NO;
    }
    for (HsPickerItem *subItem in item.subItems) {
        if ([subItem isKindOfClass:HsPickerItem.class]) {
            if (![self checkItem:subItem]) {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

@end
