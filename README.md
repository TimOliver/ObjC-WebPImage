<p align="center">
    <img src="https://github.com/TimOliver/ObjC-WebPImage/raw/main/banner.png" width="731" alt="ObjC-WebPImage Banner" />
</p>

`WebPImage` is an Objective-C library that can encode and decode data between `UIImage`
and [WebP](https://developers.google.com/speed/webp/) image files. While WebP image support was officially added to UIKit in iOS 14,
this library allows Objective-C applications to backport that functionality to older versions.

This repository is a fork of Mattt's original [`WebPImageSerialization` library](https://github.com/mattt/WebPImageSerialization).
Since Mattt has officially archived that repository, this one has been created as a wholly separate repository for those who still might need it. 

# Features

* Converts WebP image data to `UIImage` objects for display in iOS applications.
* Provides basic image scaling APIs for decoding larger images at smaller sizes, saving memory.
* Converts decompressed `UIImage` back to WebP with a variety of quality presets available.
* Provides `UIImage` method swizzling to seamlessly include WebP decoding in Apple's official APIs.

# Installation

<details>
  <summary><strong>CocoaPods</strong></summary>
    
Add the following to your `Podfile`:

```
pod 'ObjC-WebPImage'
```
      
</details>

<details>
  <summary><strong>Manual Installation</strong></summary>
    
    1. Download this repository.
    2. Copy the `WebPImage` folder to your Xcode project.
    3. Download the precompiled `WebP.xcframework` binary from [the Cocoa-WebP repo](https://github.com/TimOliver/WebP-Cocoa) for iOS.
    4. Drag that framework into your Xcode project.
      
</details>

# Usage

`WebPImage` provides two major sets of functionality: decoding WebP data from a file into a `UIImage`, 
and conversely, encoding a `UIImage` back to WebP image data.

## Decoding

```objective-c
UIImageView *imageView = ...;
imageView.image = [UIImage imageNamed:@"image.webp"];
```

## Encoding

```objective-c
NSData *data = UIImageWebPRepresentation(imageView.image);
```

### UIKit Integration

By default, `UIImage` initializers can't decode animated images from GIF files.
This library uses swizzling to provide this functionality for you.
To opt out of this behavior,
set `WEBP_NO_UIIMAGE_INITIALIZER_SWIZZLING` in your build environment.
If you're using CocoaPods,
you can add this build setting to your `Podfile`:

```ruby
post_install do |r|
  r.pods_project.targets.each do |target|
    if target.name == 'WebPImageSerialization' then
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||=
          ['$(inherited)', 'WEBP_NO_UIIMAGE_INITIALIZER_SWIZZLING=1']
      end
    end
  end
end
```

## Credits

`WebPImag` is maintained by [Tim Oliver](https://twitter.com/TimOliverAU) as a component of [iComics](http://icomics.co). 
It is based on `WebPImageSerialization`, originally created by [Mattt](http://twitter.com/mattt).

## License

`WebPImage` is available under the MIT license. See the LICENSE file for more info.
