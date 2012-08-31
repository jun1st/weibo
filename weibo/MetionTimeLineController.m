//
//  MetionTimeLineController.m
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "MetionTimeLineController.h"
#import "Mention+CoreData.h"
#import "WBManagedObjectContext.h"
#import "MentionTableCellView.h"
#import "User.h"
#import "User+ProfileImage.h"

@interface MetionTimeLineController()

@property (readonly, strong) NSMutableArray *mentions;

@end

@implementation MetionTimeLineController

@synthesize mentions = _mentions;

-(NSMutableArray *)mentions
{
    if (!_mentions) {
        _mentions = [[NSMutableArray alloc] init];
        
        NSArray *mentions = [Mention metionsFromContext:[[WBManagedObjectContext sharedInstance] managedObjectContext]];
        
        [_mentions removeAllObjects];
        [_mentions addObjectsFromArray:mentions];
    }
    
    return _mentions;
}

-(id)init
{
    self = [super init];
    if (self) {

    }
    
    return self;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.mentions count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    MentionTableCellView *result = [tableView makeViewWithIdentifier:@"mentionCell" owner:self];
    
    Mention *mention = [self.mentions objectAtIndex:row];
    result.authName.stringValue = mention.user.screenName;
    
    if (mention.user.profileImage) {
        result.userProfileImageView.image = mention.user.profileImage;
    }
    
    NSMutableAttributedString *rString =
    [[NSMutableAttributedString alloc] initWithString:mention.text];
    
    [rString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range: NSMakeRange(0, rString.length)];
    
    [result.statusTextView.textStorage setAttributedString: rString];
    
    return result;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString *text = ((Mention *)[self.mentions objectAtIndex:row]).text;
    
    NSMutableAttributedString *rString =
    [[NSMutableAttributedString alloc] initWithString:text];
    [rString addAttribute:NSFontAttributeName value:[NSFont userFontOfSize:13] range: NSMakeRange(0, rString.length)];
    
    float rows = ceilf(rString.size.width / 360.0f);
    return (rString.size.height + 3 ) * rows + 30 > 68 ? (rString.size.height + 3) * rows + 30 : 68;
}

@end
