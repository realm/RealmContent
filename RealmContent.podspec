Pod::Spec.new do |s|
  s.name             = 'RealmContent'
  s.version          = '0.2.1'
  s.summary          = 'Realm powered content management system'

  s.description      = <<-DESC
Realm powered content management system providing built-in view controllers and views to rapidly add dynamic content to iOS apps.
                       DESC

  s.homepage         = 'https://github.com/realm-demos/RealmContent'
  # s.screenshots      = ''
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/realm-demos/RealmContent.git', :tag => s.version.to_s }
  s.author                  = { 'Realm' => 'help@realm.io' }
  s.library                 = 'c++'
  s.requires_arc            = true
  s.social_media_url        = 'https://twitter.com/realm'
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }

  s.ios.deployment_target = '9.0'
  
  s.frameworks = 'UIKit'
  
  s.dependency 'RealmSwift'
  s.dependency 'Kingfisher'
  s.dependency 'NSString+Color'
  
  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |cs|
    cs.source_files = 'RealmContent/Entities/*', 'RealmContent/Core/Classes/*', 'RealmContent/Core/View/*'  
  end
  
  s.subspec 'Markdown' do |cs|
    cs.dependency 'MMMarkdown'
  
    cs.source_files = 'RealmContent/Entities/*', 'RealmContent/Markdown/Classes/*', 'RealmContent/Markdown/View/*'
  end
end
