#
# Be sure to run `pod lib lint MLTNumberScrollAnimatedView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MLTNumberScrollAnimatedView'
  s.version          = '0.1.4'
  s.summary          = 'A user-friendly view for number scrolling animation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  MLTNumberScrollAnimatedView allows you to input a full string directly, without needing to separately set the number and coin prefix. You can use it just like a `UILabel`, but only the numbers will animate with scrolling effects.

  * Supports Auto Layout
  * Directly set a string value
  * Lightweight, with only 400 lines of code
  * Fully compatible with Swift
                       DESC

  s.homepage         = 'https://github.com/4dmoonlight/MLTNumberScrollAnimatedView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Hou Rui' => '4dmoonlight@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/4dmoonlight/MLTNumberScrollAnimatedView.git', :tag => s.version.to_s }
  s.swift_versions   = ['5.0', '5.1', '5.2', '5.3']
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'MLTNumberScrollAnimatedView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MLTNumberScrollAnimatedView' => ['MLTNumberScrollAnimatedView/Assets/*.png']
  # }

   s.frameworks = 'UIKit'
   s.dependency 'SnapKit'
end
