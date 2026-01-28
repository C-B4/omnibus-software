#
# Copyright:: Chef Software, Inc.
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

name "libffi"
default_version "3.4.4"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version("3.4.6") { source sha256: "b0dea9df23c863a7a50e825440f3ebffabd65df1497108e5d437747843895a4e" }
version("3.4.4") { source sha256: "d66c56ad259a82cf2a9dfc408b32bf5da52371500b84745f7fb8b645712df676" }
version("3.4.2") { source sha256: "540fb721619a6aba3bdeef7d940d8e9e0e6d2c193595bc243241b77ff9e93620" }
version("3.3")   { source sha256: "72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056" }

source url: "https://github.com/libffi/libffi/releases/download/v#{version}/libffi-#{version}.tar.gz"

relative_path "libffi-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env["INSTALL"] = "/opt/freeware/bin/install" if aix?

  # FIX: Explicitly set prefix and libdir to ensure correct installation paths
  configure_command = [
    "--prefix=#{install_dir}/embedded",
    "--libdir=#{install_dir}/embedded/lib",
    "--disable-option-checking",
    "--disable-docs",
    "--enable-shared",
    "--disable-static",
  ]

  if version == "3.3" && mac_os_x? && arm?
    patch source: "libffi-3.3-arm64.patch", plevel: 1, env: env
  end

  if version == "3.4.4" && rhel? && platform_version.satisfies?("~> 10.0")
    patch source: "libffi-rhel10-3.4.4-Forward-declare-open_temp_exec_file.patch", plevel: 1, env: env
  end

  unless aix?
    configure_command << "--disable-multi-os-directory"
    if version == "3.2.1"
      patch source: "libffi-3.2.1-disable-multi-os-directory.patch", plevel: 1, env: env
    end
  end

  configure(*configure_command, env: env)

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

  # libffi's default install location of header files is awful...
  mkdir "#{install_dir}/embedded/include"
  copy "#{install_dir}/embedded/lib/libffi-#{version}/include/*", "#{install_dir}/embedded/include/"

  # FIX: Ensure pkgconfig file is in the standard location
  # libffi sometimes installs to lib/pkgconfig, sometimes to lib64/pkgconfig
  mkdir "#{install_dir}/embedded/lib/pkgconfig"
  
  # Copy .pc file if it ended up in lib64
  if File.exist?("#{install_dir}/embedded/lib64/pkgconfig/libffi.pc")
    copy "#{install_dir}/embedded/lib64/pkgconfig/libffi.pc", "#{install_dir}/embedded/lib/pkgconfig/"
  end

  # Also copy any libs that ended up in lib64
  if Dir.exist?("#{install_dir}/embedded/lib64")
    copy "#{install_dir}/embedded/lib64/libffi*", "#{install_dir}/embedded/lib/"
  end
end