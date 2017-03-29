Pod::Spec.new do |spec|
  spec.name = "HKProgressHUD"
  spec.version = "0.8.1"
  spec.summary = "iOS Progress HUB in swift."
  spec.homepage = "https://github.com/huaweikang/HKProgressHUD"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Huawei Kang" => 'hackerkang1990@gmail.com' }

  spec.ios.deployment_target = '8.0'
  spec.tvos.deployment_target = '9.0'
  spec.requires_arc = true
  spec.source = { git: "https://github.com/huaweikang/HKProgressHUD.git", tag: "v#{spec.version}"}
  spec.source_files = "ProgressHUD/*.{h,swift}"
end
