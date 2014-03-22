Pod::Spec.new do |s|
  s.name     = 'ASCPictureManager'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A NSManagedObject Picture Manager.'
  s.homepage = 'https://github.com/celor/ASCPictureManager'
  s.authors  = { 'Aurelien Scelles' => 'aurelien.scelles@me.com' }
  s.source   = { :git => 'https://github.com/celor/ASCPictureManager.git', :tag => "0.0.1", :submodules => true }
  s.platform = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'Classes/ASCPictureManager.{h,m}'
    s.subspec 'UIKitCategory' do |ds|
    ds.source_files = 'Classes/*+ASCPictureManager.{h,m}'
  end
end
