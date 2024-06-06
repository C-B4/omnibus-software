#
# Copyright 2013-2018 Chef Software, Inc.
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
# Install bzip2 and its shared library, libbz2.so
# This library object is required for building Python with the bz2 module,
# and should be picked up automatically when building Python.

name "bzip2"
default_version "1.0.7"

license "BSD-2-Clause"
license_file "LICENSE"
skip_transitive_dependency_licensing true

dependency "zlib"
dependency "openssl"

version("1.0.7") { source sha512: "e0e19b493e6b1f7beeb0eeb0be8a6358c24202173f28acb1e902a768835be9e24f2cb966452fbc90fc3e4e692532ce0c7e86d06aef2d52c0d2a9ac16e12ec8c8" }

source url: "https://sourceware.org/pub/bzip2/#{name}-#{version}.tar.gz"

relative_path "#{name}-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Avoid warning where .rodata cannot be used when making a shared object
  env["CFLAGS"] << " -fPIC" unless aix?

  # The list of arguments to pass to make
  args = "PREFIX='#{install_dir}/embedded' VERSION='#{version}'"
  args << " CFLAGS='-qpic=small -qpic=large -O2 -g -D_ALL_SOURCE -D_LARGE_FILES'" if aix?

  patch source: "makefile_take_env_vars.patch", env: env
  patch source: "soname_install_dir.patch", env: env if mac_os_x?
  patch source: "aix_makefile.patch", env: env if aix?

  make "#{args}", env: env
  make "#{args} -f Makefile-libbz2_so", env: env
  make "#{args} install", env: env
end
