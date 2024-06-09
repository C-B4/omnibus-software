source "https://rubygems.org"
gemspec
gem 'ffi', '=1.15.4', override: true
gem 'ffi-yajl', '=2.4.0', override: true

group :development, :test do
  gem "omnibus", git: "https://github.com/chef/omnibus", branch: 'main'
  gem "highline"
  gem "rake"
  gem "chefstyle"
end

group :ffidep do
  gem "ffi"
  gem "ffi-yajl"
end