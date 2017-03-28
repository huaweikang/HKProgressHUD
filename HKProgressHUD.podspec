Pod::Spec.new do |spec|
  spec.name = "HKProgressHUD"
  spec.version = "0.8.0"
  spec.summary = "iOS Progress HUB in swift."
  spec.homepage = "https://github.com/huaweikang/HKProgressHUD"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Huawei Kang" => 'hackerkang1990@gmail.com' }

  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/huaweikang/HKProgressHUD.git", tag: "v#{spec.version}"}
  spec.source_files = "ProgressHUD/*.{h,swift}"
end
