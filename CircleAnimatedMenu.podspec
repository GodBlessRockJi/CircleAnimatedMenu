Pod::Spec.new do |s|
  s.name             = 'CircleAnimatedMenu'
  s.version          = '0.0.1'
  s.summary          = 'Customizable library "CircleAnimatedMenu", changed some properties '

  s.description      = <<-DESC
"CircleAnimatedMenu" - convenient customizable menu which can be used to show and select different categories. Selection can be done by sliding around the center of menu or just by tapping at section. 
                       DESC

  s.homepage         = 'https://github.com/GodBlessRockJi/CircleAnimatedMenu'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rock' => '672664351@qq.com' }
  s.source           = { :git => 'https://github.com/GodBlessRockJi/CircleAnimatedMenu.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.source_files = 'CircleAnimatedMenu/Classes/**/*.swift'

end
