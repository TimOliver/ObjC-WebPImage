Pod::Spec.new do |s|
  s.name     = 'ObjC-WebPImage'
  s.version  = '1.1.0'
  s.license  = 'MIT'
  s.summary  = 'Encodes and decodes between UIImage and WebP image data.'
  s.homepage = 'https://github.com/timoliver/ObjC-WebPImage'
  s.authors  = 'Mattt', 'Tim Oliver'
  s.source   = { git: 'https://github.com/timoliver/ObjC-WebPImage.git', tag: s.version }
  s.source_files = 'WebPImage/**/*.{h,m}'
  s.requires_arc = true

  s.ios.frameworks = 'CoreGraphics'
  s.ios.deployment_target = '9.0'

  s.dependency 'libwebp'
end
