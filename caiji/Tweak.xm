#import <Foundation/Foundation.h>

%hook NSURL

+ (instancetype)URLWithString:(NSString *)URLString {
    NSLog(@"[caiji] NSURL URLWithString: %@", URLString);
    return %orig;
}

%end

%hook NSURLRequest

+ (instancetype)requestWithURL:(NSURL *)URL {
    NSLog(@"[caiji] NSURLRequest requestWithURL: %@", URL);
    return %orig;
}

+ (instancetype)requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    NSLog(@"[caiji] NSURLRequest requestWithURL: %@ cachePolicy: %lu timeout: %.1f", URL, (unsigned long)cachePolicy, timeoutInterval);
    return %orig;
}

%end

%hook NSMutableURLRequest

- (void)setURL:(NSURL *)URL {
    NSLog(@"[caiji] NSMutableURLRequest setURL: %@", URL);
    %orig;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    NSLog(@"[caiji] NSMutableURLRequest setHeader %@: %@", field, value);
    %orig;
}

%end
