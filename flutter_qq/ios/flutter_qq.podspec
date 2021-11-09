#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_qq.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_qq'
  s.version          = '0.0.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
#  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.swift_version = '5.0'

  s.vendored_frameworks = 'TencentOpenAPI/*.framework'
#  s.preserve_paths = [ 'TencentOpenAPI/*.framework/module.modulemap', 'TencentOpenAPI/*.framework/*.h' ]
  s.frameworks = 'Security', 'SystemConfiguration', 'CoreGraphics', 'CoreTelephony', 'WebKit'
  s.libraries = 'iconv', 'sqlite3', 'stdc++', 'z'
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-fobjc-arc',
  }

  s.prepare_command = <<-EOF

    # 创建TencentOpenAPI Module
    rm -rf TencentOpenAPI/TencentOpenAPI.framework/Modules
    mkdir TencentOpenAPI/TencentOpenAPI.framework/Modules
    touch TencentOpenAPI/TencentOpenAPI.framework/Modules/module.modulemap
    cat <<-EOF > TencentOpenAPI/TencentOpenAPI.framework/Modules/module.modulemap
    framework module TencentOpenApi {
      umbrella header "TencentOpenApiUmbrellaHeader.h"
      export *
    }
    \EOF
    
  EOF

end
