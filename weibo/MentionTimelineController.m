//
//  MetionTimeLineController.m
//  weibo
//
//  Created by derek on 8/31/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "MentionTimelineController.h"
#import "Mention+CoreData.h"
#import "WBManagedObjectContext.h"
#import "MentionTableCellView.h"
#import "User.h"
#import "User+ProfileImage.h"
#import "EQSTRScrollView.h"

#define kWBMetionsUrl @"comments/mentions.json"

@interface MentionTimelineController()

@property (readonly, strong) NSMutableArray *mentions;
@property (assign)EQSTRScrollView *parentScrollView;

@end

@implementation MentionTimelineController

@synthesize mentions = _mentions;

-(NSMutableArray *)mentions
{
    if (!_mentions) {
        _mentions = [[NSMutableArray alloc] init];
        
        NSArray *objects = [Mention metionsFromContext:[[WBManagedObjectContext sharedInstance] managedObjectContext]];
        
        [_mentions removeAllObjects];
        [_mentions addObjectsFromArray:objects];
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

#pragma timeline controller delegate

-(void)pullToRefreshInScrollView:(EQSTRScrollView *)scrollView
{
    [self.engine loadRequestWithMethodName:kWBMetionsUrl
                           httpMethod:@"GET"
                               params:nil
                         postDataType:kWBRequestPostDataTypeNone
                     httpHeaderFields:nil];
    
    self.parentScrollView = scrollView;
}

-(void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        NSMutableArray *metionsDict = [dict objectForKey:@"comments"];
        
        for (int i=0; i < metionsDict.count; i++) {
            NSDictionary *metion = [metionsDict objectAtIndex:i];
            [Mention save:metion inContext:[[WBManagedObjectContext sharedInstance] managedObjectContext]];
        }
        
        
    }
    
    [self.parentScrollView stopLoading];

}

-(void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self.parentScrollView stopLoading];
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
    else{
        [self startUserProfileImageDownload:mention.user forRow:row];
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
    
    float rows = ceilf(rString.size.width / 380.0f);
    return (rString.size.height + 3 ) * rows + 30 > 68 ? (rString.size.height + 3) * rows + 30 : 68;
}

@end
