#import "UIDevice+Hardware.h"
#include <sys/sysctl.h>

@implementation UIDevice(Hardware)
- (NSString *)platform
{
    static NSString *_platform = nil;
    
    if (_platform == nil) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);

        char *buf = malloc(size);
        sysctlbyname("hw.machine", buf, &size, NULL, 0);
        
        _platform = @(buf);
        
        free(buf);
    }
    return _platform;
}

@end
