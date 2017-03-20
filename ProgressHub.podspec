Pod::Spec.new do |spec|
  spec.name = "ProgressHub"
  spec.version = "1.0.0"
  spec.summary = "swift MPProgressHUB."
  spec.homepage = "https://github.com/huaweikang/ProgressHub"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Huawei Kang" => 'hackerkang1990@gmail.com' }
  spec.social_media_url = "http://twitter.com/thoughtbot"

  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/huaweikang/ProgressHub.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "ProgressHub/**/*.{h,swift}"
end
