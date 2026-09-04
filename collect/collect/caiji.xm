#import <Foundation/Foundation.h>

%hook NSURL

+ (instancetype)URLWithString:(NSString *)URLString {
    // URL interception hook — passthrough placeholder
    // Original caiji.dylib intercepted URLs here for collect/product and child/login endpoints
    if (URLString) {
        NSLog(@"[caiji] URLWithString: %@", URLString);
    }
    return %orig;
}

%end
