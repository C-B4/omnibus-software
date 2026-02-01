#
# Copyright 2012-2016 Chef Software, Inc.
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

name "rubygems"

license "MIT"
license_file "https://raw.githubusercontent.com/rubygems/rubygems/master/LICENSE.txt"
skip_transitive_dependency_licensing true

dependency "ruby"
default_version "3.7.1"


if version && !source
  known_tarballs = {
    "2.1.11" => "b561b7aaa70d387e230688066e46e448",
    "2.2.1" => "1f0017af0ad3d3ed52665132f80e7443",
    "2.4.1" => "7e39c31806bbf9268296d03bd97ce718",
    "2.4.4" => "440a89ad6a3b1b7a69b034233cc4658e",
    "2.4.5" => "5918319a439c33ac75fbbad7fd60749d",
    "2.4.8" => "dc77b51449dffe5b31776bff826bf559",
    "2.6.7" => "9cd4c5bdc70b525dfacd96e471a64605",
    "2.6.8" => "40b3250f28c1d0d5cb9ff5ab2b17df6e",
  }
  known_tarballs.each do |vsn, md5|
    version vsn do
      source md5: md5, url: "http://production.cf.rubygems.org/rubygems/rubygems-#{vsn}.tgz"
      relative_path "rubygems-#{vsn}"
    end
  end

  version("v2.4.4_plus_debug") { source git: "https://github.com/danielsdeleo/rubygems.git" }
  version("2.4.4.debug.1")     { source git: "https://github.com/danielsdeleo/rubygems.git" }
  version("jdm/2.4.8-patched") { source git: "https://github.com/jaym/rubygems.git" }
end

if version && !source
  begin
    Gem::Version.new(version)
  rescue ArgumentError
    source git: "https://github.com/rubygems/rubygems.git"
  end
end

if source && source.include?(:git)
  relative_path "rubygems"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # === ADD THESE LINES - Force use of embedded Ruby ===
  env["PATH"] = "#{install_dir}/embedded/bin:#{env['PATH']}"
  env["LDFLAGS"] << " -L#{install_dir}/embedded/lib -Wl,-rpath,#{install_dir}/embedded/lib"
  # === END ADD ===

  if source
    ruby "setup.rb  --no-document", env: env
  else
    gem "update --no-document --system #{version}", env: env
  end
  gem "install bundler -v 2.6.9 --no-document", env: env
end