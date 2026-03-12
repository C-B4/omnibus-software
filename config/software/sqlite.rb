name "sqlite"
default_version "3.45.1"

license "Public-Domain"
skip_transitive_dependency_licensing true

version("3.45.1") { source sha256: "cd9c27841b7a5932c9897651e20b86c701dd740556989b01ca596fcfa3d49a0a" }

# SQLite uses a year + version encoding: 3.45.1 = 3450100
source url: "https://www.sqlite.org/2024/sqlite-autoconf-3450100.tar.gz"

relative_path "sqlite-autoconf-3450100"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  configure "--prefix=#{install_dir}/embedded --disable-static", env: env

  make "-j #{workers}", env: env
  make "install", env: env
end