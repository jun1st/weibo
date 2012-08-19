/*
     File: IconDownloader.h 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  Version: 1.2 
    
 */

@class WBUser;

@protocol ImageDownloading;

@interface ImageDownloader : NSObject


@property (nonatomic, strong) WBUser *user;
@property (nonatomic, strong) NSMutableArray *rowsToUpdate;
@property (nonatomic, strong) id <ImageDownloading> delegate;

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;


- (void)startDownload;
- (void)cancelDownload;

@end

@protocol ImageDownloading 

- (void)doneLoadImageForUser:(WBUser *)user;

@end