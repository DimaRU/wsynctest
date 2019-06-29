platform :osx, '10.13'

project 'wsynctest'

def common_pods
  pod 'Moya', '13.0.1'
  pod 'PromiseKit', '6.9.0'
  pod 'PromiseKit/Alamofire', ' ~> 6'
  pod 'KeychainAccess', '3.2.0'
  pod 'OAuthSwift', '1.4.1'
  pod 'Starscream', :git => 'https://github.com/DimaRU/Starscream.git', :commit => '1dc60d8'
end

target 'wsync' do
  use_frameworks!

  # Pods for wsync
  common_pods
  
  target 'wsyncTests' do
    inherit! :search_paths
    # Pods for testing
    common_pods
  end

end

target 'wtest' do
  use_frameworks!

  # Pods for wtest
  common_pods
end

plugin 'cocoapods-keys', {
    :project => 'WuTimer',
    :keys => [
    'ClientId',
    'ClientSecret',
  ]
}
