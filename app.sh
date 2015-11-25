CFLAGS="${CFLAGS:-} -ffunction-sections -fdata-sections"
LDFLAGS="-L${DEST}/lib -L${DEPS}/lib -L${TOOLCHAIN}/lib -Wl,--gc-sections"

### ZLIB ###
_build_zlib() {
local VERSION="1.2.8"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --static
make
make install
popd
}

### LIBPOPT ###
_build_libpopt() {
local VERSION="1.16"
local FOLDER="popt-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://rpm5.org/files/popt/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" \
  --enable-static --disable-shared
make
make install
popd
}

### BINUTILS ###
_build_binutils() {
# Closest version to the toolchain
local VERSION="2.20.1"
local FOLDER="binutils-${VERSION}"
local FILE="${FOLDER}.tar.bz2"
local URL="http://ftp.gnu.org/gnu/binutils/${FILE}"

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
( . uncrosscompile.sh
  pushd "target/${FOLDER}"
  ./configure --prefix="${DEPS}" --host="$(./config.guess)" --target="${HOST}" \
    --disable-nls --disable-multilib --disable-werror
  make
  mkdir -p "${DEPS}/include"
  cp -afv "./bfd/bfd.h" "${DEPS}/include/"
  cp -avfR "./include/"* "${DEPS}/include/"
)
}

### OPROFILE ###
_build_oprofile() {
local VERSION="1.1.0"
local FOLDER="oprofile-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://prdownloads.sourceforge.net/oprofile/${FILE}"
local KERNEL_SOURCE="${KERNEL_SOURCE:-${HOME}/build/kernel-drobo${DROBO}/kernel}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="" --mandir="/man" \
  --enable-static --disable-shared \
  --with-kernel="${KERNEL_SOURCE}"
make
make install DESTDIR="${DEST}"
"${STRIP}" -s -R .comment -R .note -R .note.ABI-tag "${DEST}/bin/"*
popd
}

_build() {
  _build_zlib
  _build_libpopt
  _build_binutils
  _build_oprofile
  _package
}
