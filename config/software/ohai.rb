#
# Copyright:: Copyright (c) 2012-2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
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

name "ohai"
default_version "18.1.0"

license "Apache-2.0"
license_file "LICENSE"

version("18.1.0") { source sha256: "fa04e06231835ec4c728f00f1fd23f7939ff6886619dbf4a18cc1796379de933" }


source url: "https://rubygems.org/downloads/ohai-#{version}.gem"

dependency "ruby"
dependency "rubygems"
dependency "bundler"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem "install ohai-#{version}.gem --no-document", env: env
end