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

-(void)mentionsFromContext
{
    NSArray *objects = [Mention metionsFromContext:[[WBManagedObjectContext sharedInstance] managedObjectContext]];
    
    [self.mentions removeAllObjects];
    [self.mentions addObjectsFromArray:objects];
    

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
        
        [self mentionsFromContext];
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
    
    //match user names
    NSArray *matches = [self.userRegularExpression matchesInString:mention.text
                                                           options:0
                                                             range:NSMakeRange(0, [mention.text length])];
    for(NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        NSFont *font = [NSFont userFontOfSize:13];
        NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                      traits:NSBoldFontMask weight:0 size:13];
        [rString addAttribute:NSFontAttributeName value:boldFont range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:matchRange];
    }
    
    //match urls
    NSArray *urlMatches = [self.urlRegularExpression matchesInString:mention.text options:0 range:NSMakeRange(0, mention.text.length)];
    for (NSTextCheckingResult  *match in urlMatches) {
        NSRange matchRange = [match range];
        NSString *subString = [mention.text substringWithRange:matchRange];
        
        [rString addAttribute:NSLinkAttributeName value:subString range:matchRange];
        [rString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:matchRange];
        [rString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:matchRange];
    }
    NSMutableParagraphStyle * myStyle = [[NSMutableParagraphStyle alloc] init];
    [myStyle setLineSpacing:4.0];
    [rString addAttribute:NSParagraphStyleAttributeName value:myStyle range:NSMakeRange(0, mention.text.length)];
    
    
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
