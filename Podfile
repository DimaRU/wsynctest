platform :osx, '10.13'

project 'wsynctest'

def common_pods
  pod 'Moya', '13.0.1'
  pod 'PromiseKit', '6.8.4'
  pod 'PromiseKit/Alamofire', '6.8.4'
  pod 'KeychainAccess', '3.2.0'
  pod 'OAuthSwift', :git => 'https://github.com/DimaRU/OAuthSwift.git', :commit => 'f8ee2b1'
  pod 'Starscream', '3.1.0'
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
