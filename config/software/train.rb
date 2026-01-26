#
# Copyright 2016 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "train"
default_version "master"

source git: "https://github.com/chef/train.git"

license "Apache-2.0"
license_file "LICENSE"

dependency "ruby"
dependency "rubygems"
dependency "bundler"
dependency "google-protobuf"
dependency "libffi"
dependency "zlib"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Force embedded Ruby and tools first in PATH
  env["PATH"] = "#{install_dir}/embedded/bin:#{env['PATH']}"

  # Library linking - build time and runtime
  env["LDFLAGS"] << " -L#{install_dir}/embedded/lib -Wl,-rpath,#{install_dir}/embedded/lib"
  env["LD_LIBRARY_PATH"] = "#{install_dir}/embedded/lib"

  # Header files for native extensions
  env["CFLAGS"] << " -I#{install_dir}/embedded/include"
  env["CPPFLAGS"] ||= ""
  env["CPPFLAGS"] << " -I#{install_dir}/embedded/include"

  # pkg-config for libraries like libffi, zlib
  env["PKG_CONFIG_PATH"] = "#{install_dir}/embedded/lib/pkgconfig"

  # Exclude test and tools groups which contain byebug, ed25519, etc.
  bundle "install --without development test integration tools", env: env

  gem "build train.gemspec", env: env
  gem "install train-*.gem --no-document", env: env
end