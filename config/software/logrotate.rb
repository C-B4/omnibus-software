#
# Copyright 2013-2014 Chef Software, Inc.
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

name "logrotate"
default_version "3.18.1"

license "GPL-2.0"
license_file "COPYING"
skip_transitive_dependency_licensing true

dependency "popt"

source url: "https://github.com/logrotate/logrotate/archive/#{version}.tar.gz"

version("3.18.1") { source md5: "2aa6338b037e04548c8bffc73da24d7c"}
version("3.9.2") { source md5: "584bca013dcceeb23b06b27d6d0342fb" }
version("3.8.9") { source md5: "e6da1f1b91d1f202d26caaf864aa0d71" }

relative_path "logrotate-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Disable warnings-as-errors for newer GCC compatibility
  # GCC 11+ has stricter warnings that flag issues in logrotate 3.9.2
  env["CFLAGS"] << " -Wno-error=misleading-indentation -Wno-error=stringop-overflow"

  # Run autogen.sh to generate configure script
  command "./autogen.sh", env: env

  # Configure with proper prefix and disable SELinux (not needed for embedded use)
  configure_options = [
    "--prefix=#{install_dir}/embedded",
    "--with-popt=#{install_dir}/embedded",
    "--without-selinux"
  ]

  configure(*configure_options, env: env)

  make "-j #{workers}", env: env
  make "install", env: env
end