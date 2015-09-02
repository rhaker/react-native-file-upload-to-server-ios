//
//  RNFileUploadToServer.m
//  RNFileUploadToServer
//
//  Created by Ross Haker on 8/30/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "RNFileUploadToServer.h"

@implementation RNFileUploadToServer

// Expose this module to the React Native bridge
RCT_EXPORT_MODULE()

// Persist data
RCT_EXPORT_METHOD(uploadFile:(NSDictionary *)uploadObject
                  errorCallback:(RCTResponseSenderBlock)failureCallback
                  callback:(RCTResponseSenderBlock)successCallback) {
    
    
    // Set basic parameters
    NSString *filename = uploadObject[@"filename"];
    NSString *uploadUrl = uploadObject[@"uploadUrl"];
    NSDictionary *fields = uploadObject[@"fields"];
    
    // Set the method and headers (post/json)
    NSString *method = @"POST";
    NSDictionary *headers = @{@"Accept" : @"application/json"};
    
    // Validate the file name has positive length
    if ([filename length] < 1) {
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : @"Your file does not have a name."
                                      };
        
        // Execute the JavaScript failure callback handler and halt
        failureCallback(@[resultsDict]);
        return;
    }
    
    // Validate the file name has at least 3 characters
    if ([uploadUrl length] < 3) {
        NSDictionary *resultsDict = @{
                                      @"success" : @NO,
                                      @"errMsg"  : @"Your uploadUrl is invalid."
                                      };
        
        // Execute the JavaScript failure callback handler and halt
        failureCallback(@[resultsDict]);
        return;
    }
    
    // Convert the uploadUrl
    NSURL *url = [NSURL URLWithString:uploadUrl];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:method];
    
    // Convert the headers
    NSString *formBoundaryString = [self generateBoundaryString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", formBoundaryString];
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    for (NSString *key in headers) {
        id val = [headers objectForKey:key];
        if ([val respondsToSelector:@selector(stringValue)]) {
            val = [val stringValue];
        }
        if (![val isKindOfClass:[NSString class]]) {
            continue;
        }
        [req setValue:val forHTTPHeaderField:key];
    }
    
    // Set starting boundary
    NSData *formBoundaryData = [[NSString stringWithFormat:@"--%@\r\n", formBoundaryString] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* reqBody = [NSMutableData data];
    
    // Add fields (optional)
    for (NSString *key in fields) {
        id val = [fields objectForKey:key];
        if ([val respondsToSelector:@selector(stringValue)]) {
            val = [val stringValue];
        }
        if (![val isKindOfClass:[NSString class]]) {
            continue;
        }
        
        [reqBody appendData:formBoundaryData];
        [reqBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [reqBody appendData:[val dataUsingEncoding:NSUTF8StringEncoding]];
        [reqBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // Add files - set filepath to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    // Set the data
    NSData *fileData = [NSData dataWithContentsOfFile:filepath];
    
    // Start appending to body for file upload
    [reqBody appendData:formBoundaryData];
    [reqBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", filename, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Handle the mimeType
    [reqBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", [self mimeTypeForPath:filename]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Finalize the body for file upload
    [reqBody appendData:[[NSString stringWithFormat:@"Content-Length: %ld\r\n\r\n", (long)[fileData length]] dataUsingEncoding:NSUTF8StringEncoding]];
    [reqBody appendData:fileData];
    [reqBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Add end boundary
    NSData* end = [[NSString stringWithFormat:@"--%@--\r\n", formBoundaryString] dataUsingEncoding:NSUTF8StringEncoding];
    [reqBody appendData:end];
    
    // Send request
    [req setHTTPBody:reqBody];
    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
    NSInteger statusCode = [response statusCode];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSDictionary *res=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:statusCode],@"status",returnString,@"data",nil];
    
    // Check if the status was ok by server
    if (statusCode == 200) {
        
        // Show success message
        NSDictionary *resultsDict = @{
                                      @"success" : @YES,
                                      @"successMsg"  : returnString
                                      };
        
        // Call the JavaScript sucess handler
        successCallback(@[resultsDict]);
        return;
        
    } else {
        
        // Show error message
        res = @{
                @"success" : @YES,
                @"errMsg"  : @"Status code not OK"
                };
        
        
        // Show error message
        failureCallback(@[res]);
        return;
        
    }
    
}

// Logic to generate boundary string for post
- (NSString *)generateBoundaryString
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [NSString stringWithFormat:@"----%@", uuid];
}

// Logic to generate the mimeTye - defaults to octet stream
- (NSString *)mimeTypeForPath:(NSString *)filepath
{
    NSString *fileExtension = [filepath pathExtension];
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    
    if (contentType) {
        return contentType;
    }
    return @"application/octet-stream";
    
}

@end
