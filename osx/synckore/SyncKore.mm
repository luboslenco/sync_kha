#include <SyncKore.h>

#include <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface SyncServiceBrowserController : NSObject <NSNetServiceBrowserDelegate> {

	NSNetServiceBrowser     *browser;
    NSMutableArray          *services;
}

-(void) discover;
-(void) sync:(const char*) str;

@end

@implementation SyncServiceBrowserController

- (id)init {
    self = [super init];

    browser = [[NSNetServiceBrowser alloc] init];
    services = [[NSMutableArray array] retain];
    [browser setDelegate:self];
    [browser searchForServicesOfType:@"_iPhoneSyncService._tcp." inDomain:@""];

    return self;
}

-(void) discover {
    [services removeAllObjects];
    
    [browser stop];
    [browser searchForServicesOfType:@"_iPhoneSyncService._tcp." inDomain:@""];
}

-(void) sync:(const char*) str {
    NSNetService *service = [services objectAtIndex: 0]; // Only first found device for now
    
    NSString* data = [[NSString alloc] initWithUTF8String:str];
    NSData* appData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    if(service) {
        NSOutputStream *outStream;
        [service getInputStream:nil outputStream:&outStream];
        [outStream open];
        [outStream write:static_cast<const uint8_t *>([appData bytes]) maxLength: [appData length]];
        [outStream close];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services addObject:aNetService];
    [aNetService resolveWithTimeout:5.0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services removeObject:aNetService];
}

@end

namespace SyncKore {

	SyncServiceBrowserController *ssc;

	void init() {
		ssc = [[SyncServiceBrowserController alloc] init];
	}

	void discover() {
		[ssc discover];
	}

    void sync(const char* str) {
        [ssc sync:str];
    }
}
