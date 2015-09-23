
Pod::Spec.new do |spec|
  spec.name         = 'TTSwipeTabBarViewController'
  spec.version      = '0.0.1'
  spec.license = { :type => 'MIT', :text => <<-LICENSE
                   Copyright 2012
                   Permission is granted to...
                 LICENSE
               }
  spec.homepage     = 'https://github.com/tentenlee100/TTSwipeTabBarViewController'
  spec.authors      = { 'Tony tentenlee100' => 'tentenlee100@gmail.com' }
  spec.summary      = 'swipe to change tabbar select item.'
  spec.source       = { :git => 'https://github.com/tentenlee100/TTSwipeTabBarViewController.git', :tag => '0.0.1' }
  spec.source_files = 'TTSwipeTabBarViewController.{h,m}'
  spec.framework    = 'UIKit'
  spec.requires_arc = true
  spec.platform = :ios
end