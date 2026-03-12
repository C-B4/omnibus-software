#
# Copyright 2012-2015 Chef Software, Inc.
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

name "omnibus-ctl"
default_version "v0.6.12"

license "Apache-2.0"
license_file "https://raw.githubusercontent.com/chef/omnibus-ctl/master/LICENSE"
skip_transitive_dependency_licensing true

dependency "ruby"
dependency "rubygems"
dependency "bundler"

source git: "https://github.com/chef/omnibus-ctl.git"

relative_path "omnibus-ctl"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # === ADD THESE LINES - Force use of embedded Ruby ===
  env["PATH"] = "#{install_dir}/embedded/bin:#{env['PATH']}"
  env["LDFLAGS"] << " -L#{install_dir}/embedded/lib -Wl,-rpath,#{install_dir}/embedded/lib"
  # === END ADD ===

  # Remove existing built gems in case they exist in the current dir
  delete "omnibus-ctl-*.gem"

  gem "build omnibus-ctl.gemspec", env: env
  gem "install omnibus-ctl-*.gem --no-document ", env: env

  touch "#{install_dir}/embedded/service/omnibus-ctl/.gitkeep"
end