#
#  Be sure to run `pod spec lint TRCommon.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name         = "TRCommon"
  s.version      = "0.0.2"
  s.summary      = "纯碎文件."
  s.description  = <<-DESC
  实时不带工程的哈哈
                   DESC

  s.homepage     = "https://github.com/zdbreak/TRCommon"


  s.license      = "MIT"


  s.author             = { "zdbreak" => "794202707@qq.com" }
 

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/zdbreak/TRCommon.git", :tag => "#{s.version}" }



  s.source_files  = "TRMethods", "TRMethods/*.{h,m}"
  #s.exclude_files = "TRMethods/Exclude"



end
