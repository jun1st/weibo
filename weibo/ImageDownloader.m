/*
     File: IconDownloader.m 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  
 */

#import "ImageDownloader.h"
#import "User.h"
#import "User+ProfileImage.h"

@interface ImageDownloader()


@end

@implementation ImageDownloader

@synthesize user = _user;

@synthesize activeDownload = _activeDownload;
@synthesize imageConnection = _imageConnection;

@synthesize delegate = _delegate;
@synthesize rowsToUpdate = _rowsToUpdate;

-(NSMutableArray *)rowsToUpdate
{
    if (_rowsToUpdate == nil) {
        _rowsToUpdate = [[NSMutableArray alloc] init];
    }
    
    return _rowsToUpdate;
}

#pragma mark

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    
    NSString *imageUrl = self.user.profileImageUrl;
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:imageUrl]] delegate:self];
    self.imageConnection = conn;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    NSLog(@"%@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSData *data = [[NSData alloc] initWithData:self.activeDownload];
    NSString *filePath = [[[User profileImageDirectory] URLByAppendingPathComponent:self.user.idstr] absoluteString];
   
    [data writeToFile:filePath atomically:YES];
    self.activeDownload = nil;
    // Release the connection now that it's finished
    self.imageConnection = nil;

    [self.delegate doneLoadImageForUser:self.user];
}

@end

