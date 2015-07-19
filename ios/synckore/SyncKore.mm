#include <SyncKore.h>

#include <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

#define SERVICE_NAME	@"iPhone Sync Service"

@interface SyncServiceController : NSObject <NSNetServiceDelegate> {

	NSNetService	*netService;
    NSFileHandle	*listeningSocket;
	bool			serviceStarted;
}

-(id) init;
-(void) toggleSync;

@end


@implementation SyncServiceController

- (id)init 
{
	self = [super init];
    serviceStarted=NO;
    return self;
}

-(void) toggleSync {
	uint16_t chosenPort = 0;
    
    if(!listeningSocket) {
        // Here, create the socket from traditional BSD socket calls, and then set up an NSFileHandle with that to listen for incoming connections.
        int fdForListening;
        struct sockaddr_in serverAddress;
        socklen_t namelen = sizeof(serverAddress);
		
        // In order to use NSFileHandle's acceptConnectionInBackgroundAndNotify method, we need to create a file descriptor that is itself a socket, bind that socket, and then set it up for listening. At this point, it's ready to be handed off to acceptConnectionInBackgroundAndNotify.
        if((fdForListening = socket(AF_INET, SOCK_STREAM, 0)) > 0) {
            memset(&serverAddress, 0, sizeof(serverAddress));
            serverAddress.sin_family = AF_INET;
            serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
            serverAddress.sin_port = 0; // allows the kernel to choose the port for us.
			
            if(bind(fdForListening, (struct sockaddr *)&serverAddress, sizeof(serverAddress)) < 0) {
                close(fdForListening);
                return;
            }
			
            // Find out what port number was chosen for us.
            if(getsockname(fdForListening, (struct sockaddr *)&serverAddress, &namelen) < 0) {
                close(fdForListening);
                return;
            }
			
            chosenPort = ntohs(serverAddress.sin_port);
            
            if(listen(fdForListening, 1) == 0) {
                listeningSocket = [[NSFileHandle alloc] initWithFileDescriptor:fdForListening closeOnDealloc:YES];
            }
        }
    }
    
    if(!netService) {
        // lazily instantiate the NSNetService object that will advertise on our behalf.
        netService = [[NSNetService alloc] initWithDomain:@"" type:@"_iPhoneSyncService._tcp." name:SERVICE_NAME port:chosenPort];
        [netService setDelegate:self];
    }
    
    if(netService && listeningSocket) {
        if(!serviceStarted) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionReceived:) name:NSFileHandleConnectionAcceptedNotification object:listeningSocket];
            [listeningSocket acceptConnectionInBackgroundAndNotify];
            [netService publish];
			serviceStarted = YES;
			
        } else {
            [netService stop];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:listeningSocket];
            // There is at present no way to get an NSFileHandle to -stop- listening for events, so we'll just have to tear it down and recreate it the next time we need it.
            //[listeningSocket release];
            listeningSocket = nil;
			serviceStarted = NO;
        }
    }
	
}

- (void)connectionReceived:(NSNotification *)aNotification {
    NSFileHandle *incomingConnection = [[aNotification userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
	
    [[aNotification object] acceptConnectionInBackgroundAndNotify];
	
    NSData *receivedData = [incomingConnection availableData];
    
    NSString *strData = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strData);
	
    [incomingConnection closeFile];
}

@end

namespace SyncKore {

	SyncServiceController *ssc;

	void init() {
		ssc = [[SyncServiceController alloc] init];
	}

	void toggleSync() {
		[ssc toggleSync];
	}
}
