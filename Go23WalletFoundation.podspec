#
# Be sure to run `pod lib lint Go23WalletFoundation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Go23WalletFoundation'
  s.version          = '1.0.0'
  s.summary          = 'Go23Wallet functionality'

  s.description      = <<-DESC
  Core wallet functionality
                       DESC

  s.homepage         = 'https://github.com/Taran/Go23WalletFoundation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Taran' => 'NA' }
  s.source           = { :git => 'https://github.com/Taran/Go23WalletFoundation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.platform         = :ios, "13.0"
  
  s.source_files = 'Go23WalletFoundation/Classes/**/*.{h,m,swift}'
  s.resource_bundles = {'Go23WalletFoundation' => ['Go23WalletFoundation/Class/**/*.{graphql,json}'] }
  s.pod_target_xcconfig = { 'SWIFT_OPTIMIZATION_LEVEL' => '-Owholemodule' }
  
  # s.resource_bundles = {
  #   'Go23WalletFoundation' => ['Go23WalletFoundation/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.dependency 'BigInt', '~> 3.1'
  s.dependency 'JSONRPCKit', '~> 2.0.0'
  s.dependency 'APIKit', '5.1.0'
  s.dependency 'RealmSwift', '10.27.0'
  s.dependency 'CryptoSwift', '~> 1.4'
#  s.dependency 'AlphaWalletWeb3Provider'
  s.dependency 'TrezorCrypto'
#  s.dependency 'TrustKeystore'
  s.dependency 'SwiftyJSON', '5.0.0'
#  s.dependency 'web3swift'
  s.dependency 'PromiseKit/CorePromise'
  s.dependency 'PromiseKit/Alamofire'
  s.dependency 'Kanna'
  s.dependency 'TrustWalletCore', '2.6.34'
#  s.dependency 'EthereumABI'
  s.dependency 'BlockiesSwift'
  s.dependency 'CocoaLumberjack', '3.7.0'
  s.dependency 'PaperTrailLumberjack/Swift'
  s.dependency 'Go23WalletAddress'
  s.dependency 'Go23WalletCore'
  s.dependency 'Go23WalletGoBack'
  s.dependency 'Go23WalletENS'
  s.dependency 'DerbyWalletOpenSea'
  s.dependency 'Apollo', '0.53.0'
  s.dependency 'CombineExt', '1.8.0'
  s.dependency 'SwiftProtobuf', '~> 1.18.0'
end
