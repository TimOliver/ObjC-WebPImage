// WebPImage.m
//
// Copyright (c) 2014 – 2022 Mattt (http://mat.tt/) & Tim Oliver (http://tim.dev)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "WebPImage.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
#if __has_include(<WebP/encode.h>) && __has_include(<WebP/decode.h>)
#import <WebP/encode.h>
#import <WebP/decode.h>
#elif __has_include(<libwebp/encode.h>) && __has_include(<libwebp/decode.h>)
#import <libwebp/encode.h>
#import <libwebp/decode.h>
#else
@import WebP;
#endif
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

NSString * const WebPImageErrorDomain = @"com.webp.image.error";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-macros"
#define WebPImageDefaultPreset WEBP_PRESET_DEFAULT
#define WebPImagePicturePreset WEBP_PRESET_PICTURE
#define WebPImagePhotoPreset WEBP_PRESET_PHOTO
#define WebPImageDrawingPreset WEBP_PRESET_DRAWING
#define WebPImageIconPreset WEBP_PRESET_ICON
#define WebPImageTextPreset WEBP_PRESET_TEXT
#pragma clang diagnostic pop

static inline BOOL WebPDataIsValid(NSData *data) {
    if (data && data.length > 0) {
        int width = 0, height = 0;
        return WebPGetInfo(data.bytes, data.length, &width, &height) && width > 0 && height > 0;
    }

    return NO;
}

static NSString * WebPLocalizedDescriptionForVP8StatusCode(VP8StatusCode status) {
    switch (status) {
        case VP8_STATUS_OUT_OF_MEMORY:
            return NSLocalizedStringFromTable(@"VP8 out of memory", @"WebPImage", nil);
        case VP8_STATUS_INVALID_PARAM:
            return NSLocalizedStringFromTable(@"VP8 invalid parameter", @"WebPImage", nil);
        case VP8_STATUS_BITSTREAM_ERROR:
            return NSLocalizedStringFromTable(@"VP8 bitstream error", @"WebPImage", nil);
        case VP8_STATUS_UNSUPPORTED_FEATURE:
            return NSLocalizedStringFromTable(@"VP8 unsupported feature", @"WebPImage", nil);
        case VP8_STATUS_SUSPENDED:
            return NSLocalizedStringFromTable(@"VP8 suspended", @"WebPImage", nil);
        case VP8_STATUS_USER_ABORT:
            return NSLocalizedStringFromTable(@"VP8 user Abort", @"WebPImage", nil);
        case VP8_STATUS_NOT_ENOUGH_DATA:
            return NSLocalizedStringFromTable(@"VP8 not enough data", @"WebPImage", nil);
        case VP8_STATUS_OK:
            return NSLocalizedStringFromTable(@"VP8 unknown error", @"WebPImage", nil);
    }
}

static void WebPFreeImageData(void *info, const void *data, size_t size) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcast-qual"
    free((void *)data);
#pragma clang diagnostic pop
}

__attribute__((overloadable)) UIImage * _Nullable UIImageWithWebPData(NSData *data) {
    return UIImageWithWebPData(data, 1.0, nil);
}

__attribute__((overloadable)) UIImage * _Nullable UIImageWithWebPData(NSData *data, CGFloat scale, NSError * __autoreleasing *error) {
    return UIImageWithWebPData(data, scale, CGSizeZero, error);
}
    
__attribute__((overloadable)) UIImage * _Nullable UIImageWithWebPData(NSData *data, CGFloat scale, CGSize fittingSize, NSError * __autoreleasing *error) {
    NSDictionary *userInfo = nil;
    {
        WebPDecoderConfig config;
        int width = 0, height = 0;

        WebPBitstreamFeatures features;
        if (WebPGetFeatures([data bytes], [data length], &features) != VP8_STATUS_OK) {
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"WebP header formatting error", @"WebPImage", nil)
                        };
            goto _error;
        }
        width = features.width;
        height = features.height;

        if (!WebPInitDecoderConfig(&config)) {
            userInfo = @{
                         NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"WebP image failed to initialize structure", @"WebPImage", nil)
                        };
            goto _error;
        }

        config.output.colorspace = MODE_rgbA;
        config.options.bypass_filtering = true;
        config.options.no_fancy_upsampling = true;
        config.options.use_threads = true;

        if (fittingSize.width > 0.0 && fittingSize.height > 0.0) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wgnu"
            CGFloat sizeScale = MIN(fittingSize.width / (CGFloat)width, fittingSize.height / (CGFloat)height);
            #pragma clang diagnostic pop
            
            config.options.use_scaling = true;
            config.options.scaled_width = (int)(width * sizeScale);
            config.options.scaled_height = (int)(height * sizeScale);
        }
        
        VP8StatusCode status = WebPDecode([data bytes], [data length], &config);
        if (status != VP8_STATUS_OK) {
            userInfo = @{
                         NSLocalizedDescriptionKey: WebPLocalizedDescriptionForVP8StatusCode(status)
                        };
            goto _error;
        }

        size_t bitsPerComponent = 8;
        size_t bitsPerPixel = 32;
        size_t bytesPerRow = 4;
        CGDataProviderRef provider = CGDataProviderCreateWithData(&config, config.output.u.RGBA.rgba, config.output.width * config.output.height * bytesPerRow, WebPFreeImageData);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
        bitmapInfo |= features.has_alpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast;
        CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
        BOOL shouldInterpolate = YES;

        CGImageRef imageRef = CGImageCreate((size_t)config.output.width, (size_t)config.output.height, bitsPerComponent, bitsPerPixel, bytesPerRow * config.output.width, colorSpace, bitmapInfo, provider, NULL, shouldInterpolate, renderingIntent);

        UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];

        CGImageRelease(imageRef);
        CGColorSpaceRelease(colorSpace);
        CGDataProviderRelease(provider);

        return image;
    }
    _error: {
        if (error) {
            *error = [[NSError alloc] initWithDomain:WebPImageErrorDomain code:-1 userInfo:userInfo];
        }

        return nil;
    }
}

extern __attribute__((overloadable)) NSData * _Nullable UIImageWebPRepresentation(UIImage *image) {
    return UIImageWebPRepresentation(image, (WebPImagePreset)WebPImageDefaultPreset, 75.0, nil);
}

__attribute__((overloadable)) NSData * _Nullable UIImageWebPRepresentation(UIImage *image, WebPImagePreset preset, CGFloat quality, NSError * __autoreleasing *error) {
    NSCParameterAssert(quality >= 0.0 && quality <= 100.0);

    CGImageRef imageRef = image.CGImage;
    NSDictionary *userInfo = nil;
    {
        CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
        CFDataRef dataRef = CGDataProviderCopyData(dataProvider);

        WebPConfig config;
        WebPPicture picture;

        if (!WebPConfigPreset(&config, (WebPPreset)preset, quality)) {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"WebP image configuration preset initialization failed.", @"WebPImage", nil)};
            goto _error;
        }

        if (!WebPValidateConfig(&config)) {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"WebP image invalid configuration.", @"WebPImage", nil)};
            goto _error;
        }

        if (!WebPPictureInit(&picture)) {
            userInfo = @{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"WebP image failed to initialize structure.", @"WebPImage", nil)};
            goto _error;
        }

        size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);

        picture.colorspace = WEBP_YUV420;
        picture.width = (int)width;
        picture.height = (int)height;

        WebPPictureImportRGBA(&picture, (const uint8_t *)CFDataGetBytePtr(dataRef), (int)bytesPerRow);
        WebPPictureARGBToYUVA(&picture, picture.colorspace);
        WebPCleanupTransparentArea(&picture);

        CFRelease(dataRef);

        WebPMemoryWriter writer;
        WebPMemoryWriterInit(&writer);
        picture.writer = WebPMemoryWrite;
        picture.custom_ptr = &writer;
        WebPEncode(&config, &picture);

        NSData *data = [NSData dataWithBytes:writer.mem length:writer.size];
        
        WebPPictureFree(&picture);

        return data;
    }
    _error: {
        if (error) {
            *error = [[NSError alloc] initWithDomain:WebPImageErrorDomain code:-1 userInfo:userInfo];
        }
        
        CFRelease(imageRef);
        
        return nil;
    }
}

@implementation WebPImage

+ (UIImage * _Nullable)imageWithData:(NSData *)data
                               error:(NSError * __autoreleasing *)error
{
    return [self imageWithData:data scale:1.0 error:error];
}

+ (UIImage * _Nullable)imageWithData:(NSData *)data
                               scale:(CGFloat)scale
                               error:(NSError * __autoreleasing *)error
{
    return UIImageWithWebPData(data, scale, error);
}

+ (UIImage * _Nullable)imageWithData:(NSData *)data
                               scale:(CGFloat)scale
                         fittingSize:(CGSize)fittingSize
                               error:(NSError * __autoreleasing *)error
{
    return UIImageWithWebPData(data, scale, fittingSize, error);
}

#pragma mark -

+ (NSData * _Nullable)dataWithImage:(UIImage *)image
                              error:(NSError * __autoreleasing *)error
{
    return [self dataWithImage:image preset:(WebPImagePreset)WebPImageDefaultPreset quality:1.0 error:error];
}

+ (NSData * _Nullable )dataWithImage:(UIImage *)image
                              preset:(WebPImagePreset)preset
                             quality:(CGFloat)quality
                               error:(NSError * __autoreleasing *)error
{
    return UIImageWebPRepresentation(image, preset, quality, error);
}

@end

NS_ASSUME_NONNULL_END

#pragma mark -

#ifndef WEBP_NO_UIIMAGE_INITIALIZER_SWIZZLING
@import ObjectiveC.runtime;

static inline void webp_swizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface UIImage (_WebPImage)
@end

@implementation UIImage (_WebPImage)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            webp_swizzleSelector(self, @selector(initWithData:scale:), @selector(webp_initWithData:scale:));
            webp_swizzleSelector(self, @selector(initWithData:), @selector(webp_initWithData:));
            webp_swizzleSelector(self, @selector(initWithContentsOfFile:), @selector(webp_initWithContentsOfFile:));
            webp_swizzleSelector(object_getClass((id)self), @selector(imageNamed:), @selector(webp_imageNamed:));
        }
    });
}

NS_ASSUME_NONNULL_BEGIN

+ (UIImage *)webp_imageNamed:(NSString *)name __attribute__((objc_method_family(new))){
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    NSString *scaleSuffix = @"";
    if (scale >= 3) {
        scaleSuffix = @"@3x";
    } else if (scale >= 2) {
        scaleSuffix = @"@2x";
    }
    
    NSString * _Nullable path = nil;
   
    if (!path) {
        // e.g. image@2x.webp
        NSString *nameWithRatio = [[[name stringByDeletingPathExtension] stringByAppendingString:scaleSuffix] stringByAppendingPathExtension:[name pathExtension]];
        path = [[NSBundle mainBundle] pathForResource:nameWithRatio ofType:[name pathExtension]];
    }
    
    if (!path) {
        // e.g. image.webp
        path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
    }
    
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:(NSString * _Nonnull)path];
        if (WebPDataIsValid(data)) {
            return [WebPImage imageWithData:data error:nil];
        }
    }
    
    return [self webp_imageNamed:name];
}

- (id)webp_initWithData:(NSData *)data __attribute__((objc_method_family(init))) {
    if (WebPDataIsValid(data)) {
        return UIImageWithWebPData(data, 1.0, nil);
    }

    return [self webp_initWithData:data];
}

- (id)webp_initWithData:(NSData *)data
                  scale:(CGFloat)scale __attribute__((objc_method_family(init)))
{
    if (WebPDataIsValid(data)) {
        return UIImageWithWebPData(data, scale, nil);
    }

    return [self webp_initWithData:data scale:scale];
}

- (id)webp_initWithContentsOfFile:(NSString *)path __attribute__((objc_method_family(init))) {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (WebPDataIsValid(data)) {
        return UIImageWithWebPData(data, 1.0, nil);
    }

    return [self webp_initWithContentsOfFile:path];
}

@end

NS_ASSUME_NONNULL_END

#endif
