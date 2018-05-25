Pod::Spec.new do |s|
  s.name             = 'streams_channel'
  s.version          = '0.2.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
StreamsChannel is inspired from EventChannel. It allows to create streams of events between Flutter and platform side.
                       DESC
  s.homepage         = 'https://github.com/loup-v/streams_channel'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Loup Inc.' => 'hello@intheloup.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end

