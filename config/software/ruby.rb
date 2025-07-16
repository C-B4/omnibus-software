#
# Copyright 2012-2018, Chef Software Inc.
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

name "ruby"

license "BSD-2-Clause"
license_file "BSDL"
license_file "COPYING"
license_file "LEGAL"
skip_transitive_dependency_licensing true

default_version "3.2.0"

dependency "zlib"
dependency "openssl"
dependency "ncurses"
dependency "libffi"
dependency "libyaml"

version("3.2.0")      { source sha256: "daaa78e1360b2783f98deeceb677ad900f3a36c0ffa6e2b6b19090be77abc272" }
version("3.1.2")      { source sha256: "61843112389f02b735428b53bb64cf988ad9fb81858b8248e22e57336f24a83e" }
version("3.0.0")      { source sha256: "a13ed141a1c18eb967aac1e33f4d6ad5f21be1ac543c344e0d6feeee54af8e28" }
version("2.6.3")      { source sha256: "577fd3795f22b8d91c1d4e6733637b0394d4082db659fccf224c774a2b1c82fb" }
version("2.6.0")      { source sha256: "f3c35b924a11c88ff111f0956ded3cdc12c90c04b72b266ac61076d3697fc072" }
version("2.5.3")      { source sha256: "9828d03852c37c20fa333a0264f2490f07338576734d910ee3fd538c9520846c" }
version("2.5.1")      { source sha256: "dac81822325b79c3ba9532b048c2123357d3310b2b40024202f360251d9829b1" }
version("2.5.0")      { source sha256: "46e6f3630f1888eb653b15fa811d77b5b1df6fd7a3af436b343cfe4f4503f2ab" }
version("2.4.5")      { source sha256: "6737741ae6ffa61174c8a3dcdd8ba92bc38827827ab1d7ea1ec78bc3cefc5198" }
version("2.4.4")      { source sha256: "254f1c1a79e4cc814d1e7320bc5bdd995dc57e08727d30a767664619a9c8ae5a" }
version("2.4.3")      { source sha256: "fd0375582c92045aa7d31854e724471fb469e11a4b08ff334d39052ccaaa3a98" }
version("2.4.2")      { source sha256: "93b9e75e00b262bc4def6b26b7ae8717efc252c47154abb7392e54357e6c8c9c" }
version("2.4.1")      { source sha256: "a330e10d5cb5e53b3a0078326c5731888bb55e32c4abfeb27d9e7f8e5d000250" }
version("2.4.0")      { source sha256: "152fd0bd15a90b4a18213448f485d4b53e9f7662e1508190aa5b702446b29e3d" }
version("2.3.8")      { source sha256: "b5016d61440e939045d4e22979e04708ed6c8e1c52e7edb2553cf40b73c59abf" }
version("2.3.7")      { source sha256: "35cd349cddf78e4a0640d28ec8c7e88a2ae0db51ebd8926cd232bb70db2c7d7f" }
version("2.3.6")      { source sha256: "8322513279f9edfa612d445bc111a87894fac1128eaa539301cebfc0dd51571e" }
version("2.3.5")      { source sha256: "5462f7bbb28beff5da7441968471ed922f964db1abdce82b8860608acc23ddcc" }
version("2.3.4")      { source sha256: "98e18f17c933318d0e32fed3aea67e304f174d03170a38fd920c4fbe49fec0c3" }
version("2.3.3")      { source sha256: "241408c8c555b258846368830a06146e4849a1d58dcaf6b14a3b6a73058115b7" }
version("2.3.1")      { source sha256: "b87c738cb2032bf4920fef8e3864dc5cf8eae9d89d8d523ce0236945c5797dcd" }
version("2.3.0")      { source md5: "e81740ac7b14a9f837e9573601db3162" }
version("2.2.10")     { source sha256: "cd51019eb9d9c786d6cb178c37f6812d8a41d6914a1edaf0050c051c75d7c358" }
version("2.2.9")      { source sha256: "2f47c77054fc40ccfde22501425256d32c4fa0ccaf9554f0d699ed436beca1a6" }
version("2.2.8")      { source sha256: "8f37b9d8538bf8e50ad098db2a716ea49585ad1601bbd347ef84ca0662d9268a" }

source url: "https://cache.ruby-lang.org/pub/ruby/#{version.match(/^(\d+\.\d+)/)[0]}/ruby-#{version}.tar.gz"

relative_path "ruby-#{version}"

build do
  # FIX: Move env inside build block
  env = with_standard_compiler_flags(with_embedded_path)

  # FIX: Explicitly set library paths to ensure embedded libs are found first
  env["LDFLAGS"] = "-L#{install_dir}/embedded/lib -Wl,-rpath,#{install_dir}/embedded/lib"
  env["LD_RUN_PATH"] = "#{install_dir}/embedded/lib"
  env["LD_LIBRARY_PATH"] = "#{install_dir}/embedded/lib"
  env["CFLAGS"] ||= ""
  env["CFLAGS"] << " -I#{install_dir}/embedded/include"
  env["CPPFLAGS"] ||= ""
  env["CPPFLAGS"] << " -I#{install_dir}/embedded/include"
  env["PKG_CONFIG_PATH"] = "#{install_dir}/embedded/lib/pkgconfig"

  if mac_os_x?
    env["CFLAGS"] << " -I#{install_dir}/embedded/include/ncurses -arch x86_64 -m64 -O3 -g -pipe -Qunused-arguments"
    env["LDFLAGS"] << " -arch x86_64"
  elsif freebsd?
    env["LDFLAGS"] << " -ltinfow"
  elsif aix?
    env["LDSHARED"] = "xlc -G"
    env["CFLAGS"] = "-I#{install_dir}/embedded/include/ncurses -I#{install_dir}/embedded/include"
    env["XCFLAGS"] = "-DRUBY_EXPORT"
    env["CPPFLAGS"] = "-I#{install_dir}/embedded/include/ncurses -I#{install_dir}/embedded/include"
    env["SOLIBS"] = "-lm -lc"
    env["M4"] = "/opt/freeware/bin/m4"
  elsif windows?
    env["CFLAGS"] = "-I#{install_dir}/embedded/include -DFD_SETSIZE=2048"
    if windows_arch_i386?
      env["CFLAGS"] << " -m32 -march=i686 -O"
    else
      env["CFLAGS"] << " -m64 -march=x86-64 -O2"
    end
    env["CPPFLAGS"] = env["CFLAGS"]
    env["CXXFLAGS"] = env["CFLAGS"]
  else # including linux
    if version.satisfies?(">= 2.3.0") &&
        rhel? && platform_version.satisfies?("< 6.0")
      env["CFLAGS"] << " -O2 -g -pipe"
    else
      env["CFLAGS"] << " -O3 -g -pipe"
    end
  end

  # AIX needs /opt/freeware/bin only for patch
  patch_env = env.dup
  patch_env["PATH"] = "/opt/freeware/bin:#{env['PATH']}" if aix?

  patch source: "ruby-mkmf.patch", plevel: 1, env: patch_env

  if version == "2.4.0" || version == "2.4.1"
    patch source: "2.4_no_proxy_exception.patch", plevel: 1, env: patch_env
  end

  if rhel? &&
      platform_version.satisfies?("< 7") &&
      (version == "2.5.0")
    patch source: "prelude_25_el6_no_pragma.patch", plevel: 0, env: patch_env
  end

  if version == "2.5.1" || version == "2.4.4"
    patch source: "ruby-only-compiler-warnings-on-windows.patch", plevel: 1, env: patch_env
  end

  # FIX: Add explicit paths to embedded libraries
  configure_command = [
    "--prefix=#{install_dir}/embedded",
    "--with-out-ext=dbm,readline",
    "--enable-shared",
    "--disable-install-doc",
    "--without-gmp",
    "--without-gdbm",
    "--without-tk",
    "--disable-dtrace",
    # FIX: Explicitly tell Ruby where to find our embedded libraries
    "--with-opt-dir=#{install_dir}/embedded",
    "--with-zlib-dir=#{install_dir}/embedded",
    "--with-libffi-dir=#{install_dir}/embedded",
    "--with-openssl-dir=#{install_dir}/embedded",
    "--with-libyaml-dir=#{install_dir}/embedded",
  ]

  configure_command << "--with-ext=psych" if version.satisfies?("< 2.3")
  configure_command << "--with-bundled-md5" if fips_mode?

  if aix?
    patch source: "ruby-aix-configure.patch", plevel: 1, env: patch_env
    patch source: "ruby_aix_openssl.patch", plevel: 1, env: patch_env
    patch source: "ruby_aix_2_1_3_ssl_EAGAIN.patch", plevel: 1, env: patch_env
    patch source: "ruby-aix-atomic.patch", plevel: 1, env: patch_env
    patch source: "ruby-aix-vm-core.patch", plevel: 1, env: patch_env
    configure_command << "--host=powerpc-ibm-aix6.1.0.0 --target=powerpc-ibm-aix6.1.0.0 --build=powerpc-ibm-aix6.1.0.0 --enable-pthread"
  elsif freebsd?
    configure_command << "ac_cv_header_execinfo_h=no"
  elsif smartos?
    patch source: "ruby-openssl-1.0.1c.patch", plevel: 1, env: patch_env unless version.satisfies?(">= 2.4.1")
    patch source: "rvm-cflags.patch", plevel: 1, env: patch_env
    configure_command << "ac_cv_func_dl_iterate_phdr=no"
  elsif solaris2?
    configure_command << "ac_cv_func_arc4random_buf=no"
  elsif windows?
    if version.satisfies?(">= 2.3") && version.satisfies?("< 2.5")
      patch source: "ruby_nano.patch", plevel: 1, env: patch_env
    end
    configure_command << " debugflags=-g"
  end

  if version == "2.3.4"
    patch source: "ruby_2_3_gcc7.patch", plevel: 0, env: patch_env
  end

  env["PKG_CONFIG"] = "/bin/true" if aix?

  configure(*configure_command, env: env)
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

  if windows?
    dlls = ["libwinpthread-1", "libstdc++-6"]
    if windows_arch_i386?
      dlls << "libgcc_s_dw2-1"
    else
      dlls << "libgcc_s_seh-1"
    end

    dlls.each do |dll|
      mingw = ENV["MSYSTEM"].downcase
      msys_path = ENV["OMNIBUS_TOOLCHAIN_INSTALL_DIR"] ? "#{ENV["OMNIBUS_TOOLCHAIN_INSTALL_DIR"]}/embedded/bin" : "C:/msys2"
      windows_path = "#{msys_path}/#{mingw}/bin/#{dll}.dll"
      if File.exist?(windows_path)
        copy windows_path, "#{install_dir}/embedded/bin/#{dll}.dll"
      else
        raise "Cannot find required DLL needed for dynamic linking: #{windows_path}"
      end
    end

    if version.satisfies?(">= 2.4")
      %w{ erb gem irb rdoc ri }.each do |cmd|
        copy "#{project_dir}/bin/#{cmd}", "#{install_dir}/embedded/bin/#{cmd}"
      end
    end

    command "attrib -r #{install_dir}/embedded/bin/rake.bat"
  end
end