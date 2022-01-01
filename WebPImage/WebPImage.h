// WebPImage.h
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

@import Foundation;

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Decoding WebP Image Data -

/// Decodes data representing a compressed WebP image file and returns the image as a `UIImage`.
/// @param data The data representing an encoded WebP image file.
extern __attribute__((overloadable)) UIImage * _Nullable UIImageWithWebPData(NSData *data);

/// Decodes data representing a compressed WebP image file and returns the image as a `UIImage`.
/// @param data The data representing an encoded WebP image file.
/// @param scale The scale factor of the returned image (eg, 2.0 for 2x Retina scaling).
/// @param error An error pointer that will be populated with an error object if the decoding fails.
extern __attribute__((overloadable)) UIImage * _Nullable UIImageWithWebPData(NSData *data,
                                                                             CGFloat scale,
                                                                             NSError * __autoreleasing *error);

/// Decodes data representing a compressed WebP image file and returns the image as a `UIImage`.
/// @param data The data representing an encoded WebP image file.
/// @param scale The scale factor of the returned image (eg, 2.0 for 2x Retina scaling).
/// @param fittingSize The size, in the relative scale size that the image will be decoded to, potentially saving memory.
/// @param error An error pointer that will be populated with an error object if the decoding fails.
extern __attribute__((overloadable)) UIImage * _Nullable UIImageWithWebPData(NSData *data,
                                                                             CGFloat scale,
                                                                             CGSize fittingSize,
                                                                             NSError * __autoreleasing *error);

#pragma mark - Encoding WebP Image Data -

/// Pre-defined settings for WebP compression, tailored for specific types of image content.
typedef NS_ENUM(NSUInteger, WebPImagePreset) {
    WebPImageDefaultPreset,
    WebPImagePicturePreset,
    WebPImagePhotoPreset,
    WebPImageDrawingPreset,
    WebPImageIconPreset,
    WebPImageTextPreset,
};

/// Encodes a UIImage to the WebP image format and returns the resulting data.
/// @param image The image to encode to WebP
extern __attribute__((overloadable)) NSData * _Nullable UIImageWebPRepresentation(UIImage *image);

/// Encodes a UIImage to the WebP image format and returns the resulting data.
/// @param image The image to encode to WebP
/// @param preset The WebP encoding profile preset to use when encoding the image.
/// @param quality Between 0.0 and 1.0, the quality at which the image will be encoded.
/// @param error An error pointer that will be populated with an error object if the encoding fails.
extern __attribute__((overloadable)) NSData * _Nullable UIImageWebPRepresentation(UIImage *image,
                                                                                  WebPImagePreset preset,
                                                                                  CGFloat quality,
                                                                                  NSError * __autoreleasing *error);

#pragma mark - WebPImage Objective-C Interface -

/// An Objective-C interface for encoding and decoding WebP image files.
@interface WebPImage : NSObject

/// Creating a UIImage from WebP data

/// Decodes data representing a compressed WebP image file and returns the image as a `UIImage`.
/// @param data The data representing an encoded WebP image file.
/// @param error An error pointer that will be populated with an error object if the decoding fails.
+ (UIImage * _Nullable)imageWithData:(NSData *)data
                               error:(NSError * __autoreleasing *)error;

/// Decodes data representing a compressed WebP image file and returns the image as a `UIImage`.
/// @param data The data representing an encoded WebP image file.
/// @param scale The scale factor of the returned image (eg, 2.0 for 2x Retina scaling).
/// @param error An error pointer that will be populated with an error object if the decoding fails.
+ (UIImage * _Nullable)imageWithData:(NSData *)data
                               scale:(CGFloat)scale
                               error:(NSError * __autoreleasing *)error;

/// Decodes data representing a compressed WebP image file and returns the image as a `UIImage`.
/// @param data The data representing an encoded WebP image file.
/// @param scale The scale factor of the returned image (eg, 2.0 for 2x Retina scaling).
/// @param fittingSize The size, in the relative scale size that the image will be decoded to, potentially saving memory.
/// @param error An error pointer that will be populated with an error object if the decoding fails.
+ (UIImage * _Nullable)imageWithData:(NSData *)data
                               scale:(CGFloat)scale
                         fittingSize:(CGSize)fittingSize
                               error:(NSError * __autoreleasing *)error;

/// Creating WebP data from decoded images

/// Encodes a UIImage to the WebP image format and returns the resulting data.
/// @param image The image to encode to WebP
/// @param error An error pointer that will be populated with an error object if the encoding fails.
+ (NSData * _Nullable)dataWithImage:(UIImage *)image
                              error:(NSError * __autoreleasing *)error;

/// Encodes a UIImage to the WebP image format and returns the resulting data.
/// @param image The image to encode to WebP
/// @param preset The WebP encoding profile preset to use when encoding the image.
/// @param quality Between 0.0 and 1.0, the quality at which the image will be encoded.
/// @param error An error pointer that will be populated with an error object if the encoding fails.
+ (NSData * _Nullable)dataWithImage:(UIImage *)image
                             preset:(WebPImagePreset)preset
                            quality:(CGFloat)quality
                              error:(NSError * __autoreleasing *)error;

@end

/// A custom NSError domain defining all WebImage generated errors.
extern NSString * const WebPImageErrorDomain;

NS_ASSUME_NONNULL_END

#endif
