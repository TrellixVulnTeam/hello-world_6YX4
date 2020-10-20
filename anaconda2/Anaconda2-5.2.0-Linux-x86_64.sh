#!/bin/sh
#
# NAME:  Anaconda2
# VER:   5.2.0
# PLAT:  linux-64
# BYTES:    632688935
# LINES: 774
# MD5:   8f8b7fe64456ef87131691bb01b15eda

export OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
unset LD_LIBRARY_PATH
if ! echo "$0" | grep '\.sh$' > /dev/null; then
    printf 'Please run using "bash" or "sh", but not "." or "source"\\n' >&2
    return 1
fi

# Determine RUNNING_SHELL; if SHELL is non-zero use that.
if [ -n "$SHELL" ]; then
    RUNNING_SHELL="$SHELL"
else
    if [ "$(uname)" = "Darwin" ]; then
        RUNNING_SHELL=/bin/bash
    else
        if [ -d /proc ] && [ -r /proc ] && [ -d /proc/$$ ] && [ -r /proc/$$ ] && [ -L /proc/$$/exe ] && [ -r /proc/$$/exe ]; then
            RUNNING_SHELL=$(readlink /proc/$$/exe)
        fi
        if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
            RUNNING_SHELL=$(ps -p $$ -o args= | sed 's|^-||')
            case "$RUNNING_SHELL" in
                */*)
                    ;;
                default)
                    RUNNING_SHELL=$(which "$RUNNING_SHELL")
                    ;;
            esac
        fi
    fi
fi

# Some final fallback locations
if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
    if [ -f /bin/bash ]; then
        RUNNING_SHELL=/bin/bash
    else
        if [ -f /bin/sh ]; then
            RUNNING_SHELL=/bin/sh
        fi
    fi
fi

if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
    printf 'Unable to determine your shell. Please set the SHELL env. var and re-run\\n' >&2
    exit 1
fi

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
THIS_FILE=$(basename "$0")
THIS_PATH="$THIS_DIR/$THIS_FILE"
PREFIX=$HOME/anaconda2
BATCH=0
FORCE=0
SKIP_SCRIPTS=0
TEST=0
USAGE="
usage: $0 [options]

Installs Anaconda2 5.2.0

-b           run install in batch mode (without manual intervention),
             it is expected the license terms are agreed upon
-f           no error if install prefix already exists
-h           print this help message and exit
-p PREFIX    install prefix, defaults to $PREFIX, must not contain spaces.
-s           skip running pre/post-link/install scripts
-u           update an existing installation
-t           run package tests after installation (may install conda-build)
"

if which getopt > /dev/null 2>&1; then
    OPTS=$(getopt bfhp:sut "$*" 2>/dev/null)
    if [ ! $? ]; then
        printf "%s\\n" "$USAGE"
        exit 2
    fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -h)
                printf "%s\\n" "$USAGE"
                exit 2
                ;;
            -b)
                BATCH=1
                shift
                ;;
            -f)
                FORCE=1
                shift
                ;;
            -p)
                PREFIX="$2"
                shift
                shift
                ;;
            -s)
                SKIP_SCRIPTS=1
                shift
                ;;
            -u)
                FORCE=1
                shift
                ;;
            -t)
                TEST=1
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$1"
                exit 1
                ;;
        esac
    done
else
    while getopts "bfhp:sut" x; do
        case "$x" in
            h)
                printf "%s\\n" "$USAGE"
                exit 2
            ;;
            b)
                BATCH=1
                ;;
            f)
                FORCE=1
                ;;
            p)
                PREFIX="$OPTARG"
                ;;
            s)
                SKIP_SCRIPTS=1
                ;;
            u)
                FORCE=1
                ;;
            t)
                TEST=1
                ;;
            ?)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$x"
                exit 1
                ;;
        esac
    done
fi

if ! bzip2 --help >/dev/null 2>&1; then
    printf "WARNING: bzip2 does not appear to be installed this may cause problems below\\n" >&2
fi

# verify the size of the installer
if ! wc -c "$THIS_PATH" | grep    632688935 >/dev/null; then
    printf "ERROR: size of %s should be    632688935 bytes\\n" "$THIS_FILE" >&2
    exit 1
fi

if [ "$BATCH" = "0" ] # interactive mode
then
    if [ "$(uname -m)" != "x86_64" ]; then
        printf "WARNING:\\n"
        printf "    Your operating system appears not to be 64-bit, but you are trying to\\n"
        printf "    install a 64-bit version of Anaconda2.\\n"
        printf "    Are sure you want to continue the installation? [yes|no]\\n"
        printf "[no] >>> "
        read -r ans
        if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
           [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
        then
            printf "Aborting installation\\n"
            exit 2
        fi
    fi
    if [ "$(uname)" != "Linux" ]; then
        printf "WARNING:\\n"
        printf "    Your operating system does not appear to be Linux, \\n"
        printf "    but you are trying to install a Linux version of Anaconda2.\\n"
        printf "    Are sure you want to continue the installation? [yes|no]\\n"
        printf "[no] >>> "
        read -r ans
        if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
           [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
        then
            printf "Aborting installation\\n"
            exit 2
        fi
    fi
    printf "\\n"
    printf "Welcome to Anaconda2 5.2.0\\n"
    printf "\\n"
    printf "In order to continue the installation process, please review the license\\n"
    printf "agreement.\\n"
    printf "Please, press ENTER to continue\\n"
    printf ">>> "
    read -r dummy
    pager="cat"
    if command -v "more" > /dev/null 2>&1; then
      pager="more"
    fi
    "$pager" <<EOF
===================================
Anaconda End User License Agreement
===================================

Copyright 2015, Anaconda, Inc.

All rights reserved under the 3-clause BSD License:

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of Anaconda, Inc. ("Anaconda, Inc.") nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ANACONDA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Notice of Third Party Software Licenses
=======================================

Anaconda Distribution contains open source software packages from third parties. These are available on an "as is" basis and subject to their individual license agreements. These licenses are available in Anaconda Distribution or at http://docs.anaconda.com/anaconda/pkg-docs. Any binary packages of these third party tools you obtain via Anaconda Distribution are subject to their individual licenses as well as the Anaconda license. Anaconda, Inc. reserves the right to change which third party tools are provided in Anaconda Distribution.

In particular, Anaconda Distribution contains re-distributable, run-time, shared-library files from the Intel(TM) Math Kernel Library ("MKL binaries"). You are specifically authorized to use the MKL binaries with your installation of Anaconda Distribution. You are also authorized to redistribute the MKL binaries with Anaconda Distribution or in the conda package that contains them. Use and redistribution of the MKL binaries are subject to the licensing terms located at https://software.intel.com/en-us/license/intel-simplified-software-license. If needed, instructions for removing the MKL binaries after installation of Anaconda Distribution are available at http://www.anaconda.com.

Anaconda Distribution also contains cuDNN software binaries from NVIDIA Corporation ("cuDNN binaries"). You are specifically authorized to use the cuDNN binaries with your installation of Anaconda Distribution. You are also authorized to redistribute the cuDNN binaries with an Anaconda Distribution package that contains them. If needed, instructions for removing the cuDNN binaries after installation of Anaconda Distribution are available at http://www.anaconda.com.


Anaconda Distribution also contains Visual Studio Code software binaries from Microsoft Corporation ("VS Code"). You are specifically authorized to use VS Code with your installation of Anaconda Distribution. Use of VS Code is subject to the licensing terms located at https://code.visualstudio.com/License.

Cryptography Notice
===================

This distribution includes cryptographic software. The country in which you currently reside may have restrictions on the import, possession, use, and/or re-export to another country, of encryption software. BEFORE using any encryption software, please check your country's laws, regulations and policies concerning the import, possession, or use, and re-export of encryption software, to see if this is permitted. See the Wassenaar Arrangement http://www.wassenaar.org/ for more information.

Anaconda, Inc. has self-classified this software as Export Commodity Control Number (ECCN) 5D992b, which includes mass market information security software using or performing cryptographic functions with asymmetric algorithms. No license is required for export of this software to non-embargoed countries. In addition, the Intel(TM) Math Kernel Library contained in Anaconda, Inc.'s software is classified by Intel(TM) as ECCN 5D992b with no license required for export to non-embargoed countries and Microsoft's Visual Studio Code software is classified by Microsoft as ECCN 5D992.c with no license required for export to non-embargoed countries.

The following packages are included in this distribution that relate to cryptography:

openssl
    The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open Source toolkit implementing the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols as well as a full-strength general purpose cryptography library.

pycrypto
    A collection of both secure hash functions (such as SHA256 and RIPEMD160), and various encryption algorithms (AES, DES, RSA, ElGamal, etc.).

pyopenssl
    A thin Python wrapper around (a subset of) the OpenSSL library.

kerberos (krb5, non-Windows platforms)
    A network authentication protocol designed to provide strong authentication for client/server applications by using secret-key cryptography.

cryptography
    A Python library which exposes cryptographic recipes and primitives.

EOF
    printf "\\n"
    printf "Do you accept the license terms? [yes|no]\\n"
    printf "[no] >>> "
    read -r ans
    while [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
          [ "$ans" != "no" ]  && [ "$ans" != "No" ]  && [ "$ans" != "NO" ]
    do
        printf "Please answer 'yes' or 'no':'\\n"
        printf ">>> "
        read -r ans
    done
    if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ]
    then
        printf "The license agreement wasn't approved, aborting installation.\\n"
        exit 2
    fi
    printf "\\n"
    printf "Anaconda2 will now be installed into this location:\\n"
    printf "%s\\n" "$PREFIX"
    printf "\\n"
    printf "  - Press ENTER to confirm the location\\n"
    printf "  - Press CTRL-C to abort the installation\\n"
    printf "  - Or specify a different location below\\n"
    printf "\\n"
    printf "[%s] >>> " "$PREFIX"
    read -r user_prefix
    if [ "$user_prefix" != "" ]; then
        case "$user_prefix" in
            *\ * )
                printf "ERROR: Cannot install into directories with spaces\\n" >&2
                exit 1
                ;;
            *)
                eval PREFIX="$user_prefix"
                ;;
        esac
    fi
fi # !BATCH

case "$PREFIX" in
    *\ * )
        printf "ERROR: Cannot install into directories with spaces\\n" >&2
        exit 1
        ;;
esac

if [ "$FORCE" = "0" ] && [ -e "$PREFIX" ]; then
    printf "ERROR: File or directory already exists: '%s'\\n" "$PREFIX" >&2
    printf "If you want to update an existing installation, use the -u option.\\n" >&2
    exit 1
fi


if ! mkdir -p "$PREFIX"; then
    printf "ERROR: Could not create directory: '%s'\\n" "$PREFIX" >&2
    exit 1
fi

PREFIX=$(cd "$PREFIX"; pwd)
export PREFIX

printf "PREFIX=%s\\n" "$PREFIX"

# verify the MD5 sum of the tarball appended to this header
MD5=$(tail -n +774 "$THIS_PATH" | md5sum -)
if ! echo "$MD5" | grep 8f8b7fe64456ef87131691bb01b15eda >/dev/null; then
    printf "WARNING: md5sum mismatch of tar archive\\n" >&2
    printf "expected: 8f8b7fe64456ef87131691bb01b15eda\\n" >&2
    printf "     got: %s\\n" "$MD5" >&2
fi

# extract the tarball appended to this header, this creates the *.tar.bz2 files
# for all the packages which get installed below
cd "$PREFIX"


if ! tail -n +774 "$THIS_PATH" | tar xf -; then
    printf "ERROR: could not extract tar starting at line 774\\n" >&2
    exit 1
fi

PRECONDA="$PREFIX/preconda.tar.bz2"
bunzip2 -c $PRECONDA | tar -xf - --no-same-owner || exit 1
rm -f $PRECONDA

PYTHON="$PREFIX/bin/python"
MSGS="$PREFIX/.messages.txt"
touch "$MSGS"
export FORCE

install_dist()
{
    # This function installs a conda package into prefix, but without linking
    # the conda packages.  It untars the package and calls a simple script
    # which does the post extract steps (update prefix files, run 'post-link',
    # and creates the conda metadata).  Note that this is all done without
    # conda.
    printf "installing: %s ...\\n" "$1"
    PKG_PATH="$PREFIX"/pkgs/$1
    PKG="$PKG_PATH".tar.bz2
    mkdir -p $PKG_PATH || exit 1
    bunzip2 -c "$PKG" | tar -xf - -C "$PKG_PATH" --no-same-owner || exit 1
    "$PREFIX/pkgs/python-2.7.15-h1571d57_0/bin/python" -E -s \
        "$PREFIX"/pkgs/.install.py $INST_OPT --root-prefix="$PREFIX" --link-dist="$1" || exit 1
    if [ "$1" = "python-2.7.15-h1571d57_0" ]; then
        if ! "$PYTHON" -E -V; then
            printf "ERROR:\\n" >&2
            printf "cannot execute native linux-64 binary, output from 'uname -a' is:\\n" >&2
            uname -a >&2
            exit 1
        fi
    fi
}

install_dist python-2.7.15-h1571d57_0
install_dist blas-1.0-mkl
install_dist ca-certificates-2018.03.07-0
install_dist conda-env-2.6.0-h36134e3_1
install_dist intel-openmp-2018.0.0-8
install_dist libgcc-ng-7.2.0-hdf63c60_3
install_dist libgfortran-ng-7.2.0-hdf63c60_3
install_dist libstdcxx-ng-7.2.0-hdf63c60_3
install_dist bzip2-1.0.6-h14c3975_5
install_dist expat-2.2.5-he0dffb1_0
install_dist gmp-6.1.2-h6c8ec71_1
install_dist graphite2-1.3.11-h16798f4_2
install_dist icu-58.2-h9c2bf20_1
install_dist jbig-2.1-hdba287a_0
install_dist jpeg-9b-h024ee3a_2
install_dist libffi-3.2.1-hd88cf55_4
install_dist libsodium-1.0.16-h1bed415_0
install_dist libtool-2.4.6-h544aabb_3
install_dist libxcb-1.13-h1bed415_1
install_dist lzo-2.10-h49e0be7_2
install_dist mkl-2018.0.2-1
install_dist ncurses-6.1-hf484d3e_0
install_dist openssl-1.0.2o-h20670df_0
install_dist patchelf-0.9-hf79760b_2
install_dist pcre-8.42-h439df22_0
install_dist pixman-0.34.0-hceecf20_3
install_dist snappy-1.1.7-hbae5bb6_3
install_dist tk-8.6.7-hc745277_3
install_dist unixodbc-2.3.6-h1bed415_0
install_dist xz-5.2.4-h14c3975_4
install_dist yaml-0.1.7-had09818_2
install_dist zlib-1.2.11-ha838bed_2
install_dist blosc-1.14.3-hdbcaa40_0
install_dist glib-2.56.1-h000015b_0
install_dist hdf5-1.10.2-hba1933b_1
install_dist libedit-3.1.20170329-h6b74fdf_2
install_dist libpng-1.6.34-hb9fc6fc_0
install_dist libssh2-1.8.0-h9cfc8f7_4
install_dist libtiff-4.0.9-he85c1e1_1
install_dist libxml2-2.9.8-h26e45fe_1
install_dist mpfr-3.1.5-h11a74b3_2
install_dist pandoc-1.19.2.1-hea2e7c5_1
install_dist readline-7.0-ha6073c6_4
install_dist zeromq-4.2.5-h439df22_0
install_dist dbus-1.13.2-h714fa37_1
install_dist freetype-2.8-hab7d2ae_1
install_dist gstreamer-1.14.0-hb453b48_1
install_dist libcurl-7.60.0-h1ad7b7a_0
install_dist libxslt-1.1.32-h1312cb7_0
install_dist mpc-1.0.3-hec55b23_5
install_dist sqlite-3.23.1-he433501_0
install_dist curl-7.60.0-h84994c4_0
install_dist fontconfig-2.12.6-h49f89f6_0
install_dist gst-plugins-base-1.14.0-hbbd80ab_1
install_dist alabaster-0.7.10-py27he5a193a_0
install_dist asn1crypto-0.24.0-py27_0
install_dist attrs-18.1.0-py27_0
install_dist backports-1.0-py27h63c9359_1
install_dist backports_abc-0.5-py27h7b3c97b_0
install_dist beautifulsoup4-4.6.0-py27h3f86ba9_1
install_dist bitarray-0.8.1-py27h14c3975_1
install_dist boto-2.48.0-py27h9556ac2_1
install_dist cairo-1.14.12-h7636065_2
install_dist cdecimal-2.3-py27h14c3975_3
install_dist certifi-2018.4.16-py27_0
install_dist chardet-3.0.4-py27hfa10054_1
install_dist click-6.7-py27h4225b90_0
install_dist cloudpickle-0.5.3-py27_0
install_dist colorama-0.3.9-py27h5cde069_0
install_dist configparser-3.5.0-py27h5117587_0
install_dist contextlib2-0.5.5-py27hbf4c468_0
install_dist dask-core-0.17.5-py27_0
install_dist decorator-4.3.0-py27_0
install_dist docutils-0.14-py27hae222c1_0
install_dist enum34-1.1.6-py27h99a27e9_1
install_dist et_xmlfile-1.0.1-py27h75840f5_0
install_dist fastcache-1.0.2-py27h14c3975_2
install_dist filelock-3.0.4-py27_0
install_dist funcsigs-1.0.2-py27h83f16ab_0
install_dist functools32-3.2.3.2-py27h4ead58f_1
install_dist futures-3.2.0-py27h7b459c0_0
install_dist glob2-0.6-py27hcea9cbd_0
install_dist gmpy2-2.0.8-py27h4cf3fa8_2
install_dist greenlet-0.4.13-py27h14c3975_0
install_dist grin-1.2.1-py27_4
install_dist heapdict-1.0.0-py27_2
install_dist idna-2.6-py27h5722d68_1
install_dist imagesize-1.0.0-py27_0
install_dist ipaddress-1.0.22-py27_0
install_dist ipython_genutils-0.2.0-py27h89fb69b_0
install_dist itsdangerous-0.24-py27hb8295c1_1
install_dist jdcal-1.4-py27_0
install_dist kiwisolver-1.0.1-py27hc15e7b5_0
install_dist lazy-object-proxy-1.3.1-py27h682c727_0
install_dist locket-0.2.0-py27h73929a2_1
install_dist lxml-4.2.1-py27h23eabaa_0
install_dist markupsafe-1.0-py27h97b2822_1
install_dist mccabe-0.6.1-py27h0e7c7be_1
install_dist mistune-0.8.3-py27h14c3975_1
install_dist mkl-service-1.1.2-py27hb2d42c5_4
install_dist mpmath-1.0.0-py27h9669132_2
install_dist msgpack-python-0.5.6-py27h6bb024c_0
install_dist multipledispatch-0.5.0-py27_0
install_dist numpy-base-1.14.3-py27h9be14a7_1
install_dist olefile-0.45.1-py27_0
install_dist pandocfilters-1.4.2-py27h428e1e5_1
install_dist parso-0.2.0-py27_0
install_dist path.py-11.0.1-py27_0
install_dist pep8-1.7.1-py27_0
install_dist pkginfo-1.4.2-py27_1
install_dist pluggy-0.6.0-py27h1f4f128_0
install_dist ply-3.11-py27_0
install_dist psutil-5.4.5-py27h14c3975_0
install_dist ptyprocess-0.5.2-py27h4ccb14c_0
install_dist py-1.5.3-py27_0
install_dist pycodestyle-2.4.0-py27_0
install_dist pycosat-0.6.3-py27ha4109ae_0
install_dist pycparser-2.18-py27hefa08c5_1
install_dist pycrypto-2.6.1-py27h14c3975_8
install_dist pycurl-7.43.0.1-py27hb7f436b_0
install_dist pyodbc-4.0.23-py27hf484d3e_0
install_dist pyparsing-2.2.0-py27hf1513f8_1
install_dist pysocks-1.6.8-py27_0
install_dist pytz-2018.4-py27_0
install_dist pyyaml-3.12-py27h2d70dd7_1
install_dist pyzmq-17.0.0-py27h14c3975_1
install_dist qt-5.9.5-h7e424d6_0
install_dist qtpy-1.4.1-py27_0
install_dist rope-0.10.7-py27hfe459b0_0
install_dist ruamel_yaml-0.15.35-py27h14c3975_1
install_dist scandir-1.7-py27h14c3975_0
install_dist send2trash-1.5.0-py27_0
install_dist simplegeneric-0.8.1-py27_2
install_dist sip-4.19.8-py27hf484d3e_0
install_dist six-1.11.0-py27h5f960f1_1
install_dist snowballstemmer-1.2.1-py27h44e2768_0
install_dist sortedcontainers-1.5.10-py27_0
install_dist sphinxcontrib-1.0-py27h1512b58_1
install_dist sqlalchemy-1.2.7-py27h6b74fdf_0
install_dist subprocess32-3.5.0-py27h14c3975_0
install_dist tblib-1.3.2-py27h51fe5ba_0
install_dist toolz-0.9.0-py27_0
install_dist typing-3.6.4-py27_0
install_dist unicodecsv-0.14.1-py27h5062da9_0
install_dist wcwidth-0.1.7-py27h9e3e1ab_0
install_dist webencodings-0.5.1-py27hff10b21_1
install_dist werkzeug-0.14.1-py27_0
install_dist wrapt-1.10.11-py27h04f6869_0
install_dist xlrd-1.1.0-py27ha77178f_1
install_dist xlsxwriter-1.0.4-py27_0
install_dist xlwt-1.3.0-py27h3d85d97_0
install_dist babel-2.5.3-py27_0
install_dist backports.shutil_get_terminal_size-1.0.0-py27h5bc021e_2
install_dist cffi-1.11.5-py27h9745a5d_0
install_dist conda-verify-2.0.0-py27hf052a9d_0
install_dist cycler-0.10.0-py27hc7354d3_0
install_dist cytoolz-0.9.0.1-py27h14c3975_0
install_dist entrypoints-0.2.3-py27h502b47d_2
install_dist harfbuzz-1.7.6-h5f0a787_1
install_dist html5lib-1.0.1-py27h5233db4_0
install_dist jedi-0.12.0-py27_1
install_dist llvmlite-0.23.1-py27hdbcaa40_0
install_dist more-itertools-4.1.0-py27_0
install_dist networkx-2.1-py27_0
install_dist nltk-3.3.0-py27_0
install_dist openpyxl-2.5.3-py27_0
install_dist packaging-17.1-py27_0
install_dist partd-0.3.8-py27h4e55004_0
install_dist pathlib2-2.3.2-py27_0
install_dist pexpect-4.5.0-py27_0
install_dist pillow-5.1.0-py27h3deb7b8_0
install_dist pycairo-1.15.4-py27h1b9232e_1
install_dist pyqt-5.9.2-py27h751905a_0
install_dist python-dateutil-2.7.3-py27_0
install_dist qtawesome-0.4.4-py27hd7914c3_0
install_dist setuptools-39.1.0-py27_0
install_dist singledispatch-3.4.0.3-py27h9bcb476_0
install_dist sortedcollections-0.6.1-py27_0
install_dist sphinxcontrib-websupport-1.0.1-py27hf906f22_1
install_dist ssl_match_hostname-3.5.0.1-py27h4ec10b9_2
install_dist sympy-1.1.1-py27hc28188a_0
install_dist traitlets-4.3.2-py27hd6ce930_0
install_dist zict-0.1.3-py27h12c336c_0
install_dist backports.functools_lru_cache-1.5-py27_1
install_dist bleach-2.1.3-py27_0
install_dist clyent-1.2.2-py27h7276e6c_1
install_dist cryptography-2.2.2-py27h14c3975_0
install_dist cython-0.28.2-py27h14c3975_0
install_dist get_terminal_size-1.0.0-haa9412d_0
install_dist gevent-1.3.0-py27h14c3975_0
install_dist isort-4.3.4-py27_0
install_dist jinja2-2.10-py27h4114e70_0
install_dist jsonschema-2.6.0-py27h7ed5aa4_0
install_dist jupyter_core-4.4.0-py27h345911c_0
install_dist navigator-updater-0.2.1-py27_0
install_dist nose-1.3.7-py27heec2199_2
install_dist pango-1.41.0-hd475d92_0
install_dist pickleshare-0.7.4-py27h09770e1_0
install_dist pyflakes-1.6.0-py27h904a57d_0
install_dist pygments-2.2.0-py27h4a8b6f5_0
install_dist pytest-3.5.1-py27_0
install_dist testpath-0.3.1-py27hc38d2c4_0
install_dist tornado-5.0.2-py27_0
install_dist wheel-0.31.1-py27_0
install_dist astroid-1.6.3-py27_0
install_dist distributed-1.21.8-py27_0
install_dist flask-1.0.2-py27_1
install_dist jupyter_client-5.2.3-py27_0
install_dist nbformat-4.4.0-py27hed7f2b2_0
install_dist pip-10.0.1-py27_0
install_dist prompt_toolkit-1.0.15-py27h1b593e1_0
install_dist pyopenssl-18.0.0-py27_0
install_dist terminado-0.8.1-py27_1
install_dist flask-cors-3.0.4-py27_0
install_dist ipython-5.7.0-py27_0
install_dist nbconvert-5.3.1-py27he041f76_0
install_dist pylint-1.8.4-py27_0
install_dist urllib3-1.22-py27ha55213b_0
install_dist ipykernel-4.8.2-py27_0
install_dist requests-2.18.4-py27hc5b0589_1
install_dist anaconda-client-1.6.14-py27_0
install_dist jupyter_console-5.2.0-py27hc6bee7e_1
install_dist notebook-5.5.0-py27_0
install_dist qtconsole-4.3.1-py27hc444b0d_0
install_dist sphinx-1.7.4-py27_0
install_dist anaconda-navigator-1.8.7-py27_0
install_dist anaconda-project-0.8.2-py27h236b58a_0
install_dist jupyterlab_launcher-0.10.5-py27_0
install_dist numpydoc-0.8.0-py27_0
install_dist widgetsnbextension-3.2.1-py27_0
install_dist ipywidgets-7.2.1-py27_0
install_dist jupyterlab-0.32.1-py27_0
install_dist spyder-3.2.8-py27_0
install_dist _ipyw_jlab_nb_ext_conf-0.1.0-py27h08a7f0c_0
install_dist jupyter-1.0.0-py27_4
install_dist astropy-2.0.6-py27h3010b51_1
install_dist bokeh-0.12.16-py27_0
install_dist bottleneck-1.2.1-py27h21b16a3_0
install_dist conda-4.5.4-py27_0
install_dist conda-build-3.10.5-py27_0
install_dist datashape-0.5.4-py27hf507385_0
install_dist h5py-2.7.1-py27ha1f6525_2
install_dist imageio-2.3.0-py27_0
install_dist matplotlib-2.2.2-py27h0e671d2_1
install_dist mkl_fft-1.0.1-py27h3010b51_0
install_dist mkl_random-1.0.1-py27h629b387_0
install_dist numpy-1.14.3-py27hcd700cb_1
install_dist numba-0.38.0-py27h637b7d7_0
install_dist numexpr-2.6.5-py27h7bf3b9c_0
install_dist pandas-0.23.0-py27h637b7d7_0
install_dist pywavelets-0.5.2-py27hecda097_0
install_dist scipy-1.1.0-py27hfc37229_0
install_dist bkcharts-0.2-py27h241ae91_0
install_dist dask-0.17.5-py27_0
install_dist patsy-0.5.0-py27_0
install_dist pytables-3.4.3-py27h02b9ad4_2
install_dist scikit-learn-0.19.1-py27h445a80a_0
install_dist odo-0.5.1-py27h9170de3_0
install_dist scikit-image-0.13.1-py27h14c3975_1
install_dist statsmodels-0.9.0-py27h3010b51_0
install_dist blaze-0.11.3-py27h5f341da_0
install_dist seaborn-0.8.1-py27h633ea1e_0
install_dist anaconda-5.2.0-py27_3


mkdir -p $PREFIX/envs

if [ "$FORCE" = "1" ]; then
    "$PYTHON" -E -s "$PREFIX"/pkgs/.install.py --rm-dup || exit 1
fi

cat "$MSGS"
rm -f "$MSGS"
$PYTHON -E -s "$PREFIX/pkgs/.cio-config.py" "$THIS_PATH" || exit 1
printf "installation finished.\\n"

if [ "$PYTHONPATH" != "" ]; then
    printf "WARNING:\\n"
    printf "    You currently have a PYTHONPATH environment variable set. This may cause\\n"
    printf "    unexpected behavior when running the Python interpreter in Anaconda2.\\n"
    printf "    For best results, please verify that your PYTHONPATH only points to\\n"
    printf "    directories of packages that are compatible with the Python interpreter\\n"
    printf "    in Anaconda2: $PREFIX\\n"
fi

if [ "$BATCH" = "0" ]; then
    # Interactive mode.
    BASH_RC="$HOME"/.bashrc
    DEFAULT=no
    printf "Do you wish the installer to prepend the Anaconda2 install location\\n"
    printf "to PATH in your %s ? [yes|no]\\n" "$BASH_RC"
    printf "[%s] >>> " "$DEFAULT"
    read -r ans
    if [ "$ans" = "" ]; then
        ans=$DEFAULT
    fi
    if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
       [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
    then
        printf "\\n"
        printf "You may wish to edit your .bashrc to prepend the Anaconda2 install location to PATH:\\n"
        printf "\\n"
        printf "export PATH=%s/bin:\$PATH\\n" "$PREFIX"
        printf "\\n"
    else
        if [ -f "$BASH_RC" ]; then
            printf "\\n"
            printf "Appending source %s/bin/activate to %s\\n" "$PREFIX" "$BASH_RC"
            printf "A backup will be made to: %s-anaconda2.bak\\n" "$BASH_RC"
            printf "\\n"
            cp "$BASH_RC" "${BASH_RC}"-anaconda2.bak
        else
            printf "\\n"
            printf "Appending source %s/bin/activate in\\n" "$PREFIX"
            printf "newly created %s\\n" "$BASH_RC"
        fi
        printf "\\n"
        printf "For this change to become active, you have to open a new terminal.\\n"
        printf "\\n"
        printf "\\n" >> "$BASH_RC"
        printf "# added by Anaconda2 installer\\n"            >> "$BASH_RC"
        printf "export PATH=\"%s/bin:\$PATH\"\\n" "$PREFIX"  >> "$BASH_RC"
    fi

    printf "Thank you for installing Anaconda2!\\n"
fi # !BATCH

if [ "$TEST" = "1" ]; then
    printf "INFO: Running package tests in a subshell\\n"
    (. "$PREFIX"/bin/activate
     which conda-build > /dev/null 2>&1 || conda install -y conda-build
     if [ ! -d "$PREFIX"/conda-bld/linux-64 ]; then
         mkdir -p "$PREFIX"/conda-bld/linux-64
     fi
     cp -f "$PREFIX"/pkgs/*.tar.bz2 "$PREFIX"/conda-bld/linux-64/
     conda index "$PREFIX"/conda-bld/linux-64/
     conda-build --override-channels --channel local --test --keep-going "$PREFIX"/conda-bld/linux-64/*.tar.bz2
    )
    NFAILS=$?
    if [ "$NFAILS" != "0" ]; then
        if [ "$NFAILS" = "1" ]; then
            printf "ERROR: 1 test failed\\n" >&2
            printf "To re-run the tests for the above failed package, please enter:\\n"
            printf ". %s/bin/activate\\n" "$PREFIX"
            printf "conda-build --override-channels --channel local --test <full-path-to-failed.tar.bz2>\\n"
        else
            printf "ERROR: %s test failed\\n" $NFAILS >&2
            printf "To re-run the tests for the above failed packages, please enter:\\n"
            printf ". %s/bin/activate\\n" "$PREFIX"
            printf "conda-build --override-channels --channel local --test <full-path-to-failed.tar.bz2>\\n"
        fi
        exit $NFAILS
    fi
fi

if [ "$BATCH" = "0" ]; then
    $PYTHON -E -s "$PREFIX/pkgs/vscode_inst.py" --is-supported
    if [ "$?" = "0" ]; then
        printf "\\n"
        printf "===========================================================================\\n"
        printf "\\n"
        printf "Anaconda is partnered with Microsoft! Microsoft VSCode is a streamlined\\n"
        printf "code editor with support for development operations like debugging, task\\n"
        printf "running and version control.\\n"
        printf "\\n"
        printf "To install Visual Studio Code, you will need:\\n"
        if [ "$(uname)" = "Linux" ]; then
            printf -- "  - Administrator Privileges\\n"
        fi
        printf -- "  - Internet connectivity\\n"
        printf "\\n"
        printf "Visual Studio Code License: https://code.visualstudio.com/license\\n"
        printf "\\n"
        printf "Do you wish to proceed with the installation of Microsoft VSCode? [yes|no]\\n"
        printf ">>> "
        read -r ans
        while [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
              [ "$ans" != "no" ]  && [ "$ans" != "No" ]  && [ "$ans" != "NO" ]
        do
            printf "Please answer 'yes' or 'no':\\n"
            printf ">>> "
            read -r ans
        done
        if [ "$ans" = "yes" ] || [ "$ans" = "Yes" ] || [ "$ans" = "YES" ]
        then
            printf "Proceeding with installation of Microsoft VSCode\\n"
            $PYTHON -E -s "$PREFIX/pkgs/vscode_inst.py" --handle-all-steps || exit 1
        fi
    fi
fi
exit 0
@@END_HEADER@@
preconda.tar.bz2                                                                                    0000664 0000772 0000773 00004064644 13301715436 014365  0                                                                                                    ustar   nwani                           nwani                           0000000 0000000                                                                                                                                                                        BZh91AY&SY��I�(���Wt������������@  @   (b��/�]� �]��'�ӞH�F$�fEQJ�;�:�
1$����2��(�{hRSǾ�,.O�� n�8�  �� }��l� >���6m`�Q"���i�   R�h�   � ��}��'g��O     <&z���U%{&��O6� "�U`�l��Z�Ҁ ( �9��:�TH]K�F��7�T� ��mb��  �0d��"�/|��Q@ǟ*_4�j�Z���[E��LbMcl�6�eR�R�$T�˩�RUI�*��Y��+��w��v@HHU����m�'cY���UASF���Qk�;���v�amvwkZ���B�#3�G�
tҴ����x���;��@�|W�V�1�6�²ի5��Ĭ�fȴ��5�M��n��4ȕ�d��(��PP����'�k(4_z�&Vj�&a����f���Zˬ�C:�K�m��[SY����-m��� �
��l��������>}S�mj��f��4*L��ik-��FjIf����m��m����4 �5��lo}�އ{�`�O��t:���6F�j�f�M	5���K6�l�-��լc�W��
�����Ph�yn�����I���T2i5�c<��Z�CY��Z�e����l�EϷk�T
�J��	A�Z�ysp}���y��Mi-,�թl3h�e�ckn��+6���)��$4��Yޠ��ek+L���V�y�q{��J�IU6mSY4SY�Q�4�&[6��Ե��U�V�j�+�\��R��R�����[���{�xءfR�����X��-i[3*����c[2m����i��,CZiR���B�5{�y|�}�������� P�����{w�TEO`2Y-�sm�v�@m�{�L�c[e5Z�F�i�[h� *� *�TU�ݰղ�s�T���
�h�7 =�lkkm`��o�2��Vk(m���l֊j(l5R�
*������۶jl�4�!S5���}��p�lőM����k��K@س*��Y�1�Ε@jF�����w*��ћ6`�����m�U���4kc6Ͳ�Ȃ�m���F�&������fqk��XAZԮ��f's+q�+�s跂�徸�o��jm���PR�[i�6m�B�L�E)���}���X��V�����}����u��ݻ�[p @���|�}�����M��Z�2ж�ڭh�*�6��v��Y5��DD�f����lf�@�� @�*� w�Ƕ�D�A��1 ����͒�4j���`i�Q@ ـ	U�`      �&���( ��r�q�=�� ��'�EtY�C,64��
� 4�jCJ�t4"�d	0�bSa��'���CM A���M0A%!DhJHh hh       @RB%=)���詴�SOҚS��G�i3Pbz��#M0i��&aLI䞃S&jM�dh ��  	�H�@��@M4�P�M�@� h4� I   �4�'�&ɥ=1��ڌ������B���� ���P�b+���(���}^�U_��}��!t.��;ЍXL02�Z[&�ݞg�gY�q����Є�q �	jؖ�[FW�'�����7u�E/	x���ZV��DA*
@�A89����a��_��������e�k�r��(߇�?�}f��rz������4�!���?�N��wO6��v�6����|���1�]c�y��6vo���m�\�'��s���h��:���.5�)���s-����5����7��1�lMCJ}�/�	��0�e��Cm���`m�������{vuM������)��A�s��Q��6����4��k�����-ߤ%1q�jZ����*g߆��}�*2ܱ'Z�/ͧ�^��W9����$��J���Vc��r�]T�B3�Xʖ>�R���޻ow�(���*�B���W�K�Z�Vժ��R���dՆ�jYb�Z*�3"�Vk5f��j¬ԩ�ЭJԪ�U��aY���MZm"��V$�5T؛AZ��V�Ui�i����[	3C*���5MZ��������jV�Zе5V͋VVm[V��*�,��KJɚ3F��֢����-�Z�eQm��&a-�T�k1�U�2
��Qb�1WY�b�m��,�ūa��DE(E���mmkkc6���Vm���il���6�m�Z��H(+#1���UEH�+6�Z�4�M[Z��� ��6���!�Θ�
�E�3�:n��V���o�i��\qV3w����{����������|{يD@U�vEF=&�>�P�^��G�����O���^n���ZHt'>�p>����f�˞[z�����'ٕY��Uk�g��x��T#��0%��x��0�j?���ϕ�=3FO�1~g��zY?C�^?��J�/��zo�g�eTH<7�~�,dE~ɏW�C���/��}�������F����}�'xg^�����o��GO
�\�M��=uĐ�_�}���o��b���u�	�`C[����^��z�����'��%���l���I*g6L���������:W�o��{>�5�������־��qֵ�}?'���}�z}�8�ߓ������e�*,��,�Y,�EDe�2�Ɖ�Ee�%)))$.���J�
���˥��`��O���~O�U�>+���������<W\g���{}��_��>���Z�w_����u����sc���ɩ����{9<��F���,������>�������3�����ϧ诳���^<}?G���ޙ���ޟ~OY��	�g7��l�Ԟ��O���;>6�9`^hi�X�%���9�q3�fy����(�0BDUZD�H)���A$���Ҕ�B�o�rP����X�"���%�����$:�~�]��b��6Q��wF���[��V��� �AX���)sBO�r̈́mI=uQW2��*�RlJ6UV�U�7��Emx�SH �M��aZ�����"*Y}�]���)>O��?9�q,���T,PP~����R!��a�aІ�`s
*%n�-�~��J�^8ȳa_������C���w��a�A�ї]���������̷og�Q[��nl�Ǽ�rb��i���zj����*��l���P��=j��<����~u{�������3�pw?5�VZ���t>������öi����Zsm�^i���V�j��=�,��0�P$� �@sW�^�l��ex�@�`;�x����������|V\��qy䶖�a�u[Vռ:��pz�2��
(!a�]��3.P@�T�� H�d�U�������
>���d��h���)):D)��������P���.�{��*�����U�v��,���}C�?�_p����/�~5�����|i��x+���N�w�4� lz���L��jK%RRj��\�¯5l�B���|i|��-���:�j��v�}4��v<+��ؿxez��3�{�WߪR_�=���cx�0�t���y"���"�}����)��������y1\��b�������],%%$Yq}��U�/A����x��륖YY{��}�{����W������Ow��O�3;{�E~���hO(�ü����EzA�x�4��>C���O
����j�g�;~#�x]�u_�׹_�b�σ�_�����?���(*Wڮ�s-���7%�߈�c�|�b��ʇ��6�	puVf����J�i$䑰�b���b�Mw�d/%a���)���wOx��}B���+��+r���V�Sj�*~�&��_������{}>9~�}����􅯲�}?�-b���>��6?U-7O6�ke����fv���Q0�A�c>ڨl�d4�\���n?��ο\7�-��ﭟ�u�:x�'L+e�!�������3��OL�kA�_�ع�z7����ا��$jl�	q0��ݫ�������:��ǿ�q�$
@Z���??�����W_���j}@���^�r�^�9p�����;x|�:Q�=�Q���+tm�G!�h�6�C�K�g4=G��=)_���}d��z�Os�P�����j��03a_�����|��K��t���Z�&��B��s6�e8ӛ@��v=F����FF�40�+�:y&�v^�|eg�O�P' @�x�:����r̐��Q�&"ost(6LC���*���q�T�
6njj_&F�SEqx���!�����Ӕ%�J��o��j�BGh���rz�9��"��.[�x�Ѧ�^���O�Ǣ��?�m��_�w�"��� g�g����B����l��z��FS�ߛ�!�WD�O����Xx^���=��|����:�k;~Z��~����ė������3��o_���:�<�c}���J�U�o�\�ň|�������}�R�[|���{(��C��=]{6�e�r��������O��/�|�����?6�{;�GeWa�|Jnz�6���g�����D��2��LtӃ���/���7b"�_O��L�������?`{i��m�w��!�c	�����];�]]z��on�����^|g�����$��Q.��)�@�7�vs�6ߧ�������*����|:��d�����N&8ۗ.�����Q����;����k�~k���gh��D�u��GQ�O�&f-�1������{g�7H����=��|�m������;k���Dɜ����Y^𤋮!�HȎ��3sc�S�ڦ�j*������g��k�m�[��cɡ���d��֨��_����J,J֣(%�s����+j��c �f����C�m�`��t�ݑ�?Z�hK�k��$�a�>��r��xu�����A���_�Sb���C�y\~KJ�����f<X}��u�E��:7�I��u��?]}^���`ñ�<L}�����)����ŎtC�^�2���7@�,�*���yd�:������G,�hT��?�5"�U ҂��1��J.-��%R����>5�q�����;�'Ĉ rr!Q������ؗ�<�A�#ۧ�}(�a�$�1�2��)���Ó�lX�������y��p��3�l�=7m�;�������~pH��Qʕ���k*%�y��D�͔���+������o��B������v��}��T_���K� �������f#���D�7����+��?�n.f������M8�r���Nǖyx{���@Š���7�{��]��N=����|!9��=N�6b6B� Y�4�-��y�!��c�7nVv9�%��÷P�����6��
���;�!���Z��F$����S��͊��_��EΑ���~�ɇ�l�Ճر��P|����5ܰR���4����݃�g��c��j��Z'�*��JS��8,���A��P����Ӳ���l+C/J{�4(�LT���.��7��_'Q/��V��-P^|�VŏFA�꧎�=8_@�t�/m��`Z!h�f���2��#-�c�Y7wPX���n,�-:��?�����t#(B��E®h?p_��������5ٚ�ł��Qn��'�TPi����5��V?K��b�a�\M=��v�	1Qk�gF����O���1D�ʵ�q\��j��S��Q�賈"3_�c4TE������_�/|����0���5��1�'W�3@�a.�aL�^�4��UFO�ђyT�Z1���|��K�o����?.3>�_�7��
��±�XN��O�N�^/�@�0�� :2>l6p��t�63F ��U���0?������X �
h���;e�p��F	���i>�]v��[p�g㟍R�m.Z��|����dr������P��W�a��/r̼�+����;�����P���0ݻ(d6gC�!aI�3�XlгC��������l0�%	�` `�C�RY2$
F�9�p��Ճ���!��2X0���I�:�@�`�"Er�RX0HtLS��=�0�y���v`3�7���u�tA���A�	�a�d��0z���PR`K��et�.���� g$,
�1`��D]@�u�$d����*ae�,�6v��@�r=�]�9��`X!���l,�J��2�49�r����0'hA!��rXg l,��C�̆C�����P�K�hg��(0p��	W�1RɂG0�(L�ᙈ]("@/A���Yz/*˙t����륫/@�"p:��IC���$�ؙ$$H�3�s���{&I`��B��B��ʓ����3������:i��۾��Z���܃3`w�����ǒ�!��C���l4� 0CC�2�6�E
H��2L �QsD�,��Hr0��a�l�=���a���48�P�,2#7`tL `$���.��\R�"�h7�2C�4JJH�0A�� �r��a�2���t��.��"��(�	X���Ap��=\9u�5s������}W���ld�O�����������OJ&)�5E	'�9%0Ė��4�껶 �?�ta�/_������FȰ�/�}%���]��KM���Pn�c��2#?� t����L0�ȁܯ�gB%{4�@���<��ҭa��@��/(^�L k����P^����QC�d�����q�^#��A��&5"�O��%3���"5Hy{��_Ï�������q����G�EaH���O�3k���4ۡ�s"iaZ��[Z!W�h`��o�ù���u��j�rLB���l8c�-&�A�����o�o��j΍���5K.O`�=r���<������7ޱ����F�!�x��_�~T���8ͽRܩYxE�31����>��Z��k��My�ӡI����X���h��_�|R.�9����Pc&'�V��a���<
0�uS��t6O��w�)�zP�����0i�hl��.X��)��r���-������NNn�����]u�f�۷puuo|��8��#q��`ݦ͛1��GW� 0���UNiɡ�l�䲓��2d�� ʓ&u�7n��ݦ�n�� d��ю`�7����,�b��Ɋ�)�:�sspz=^];�v�љ��4�=Z�C7+
#���cg&1��.9997n�7n���������ͦ��77GGG��i�i���R�pn�pi�Żf�f͖d���ozJ �D�d�#4�,���۶gnݼ�t���ުpX~\���,W2���R�cQd���L+1����C�&��������@��uq�AE#�\�d�-AHjQ��qR���R.�UH�7r�Z+Lu�
k�Qʥe�_��*m�Q�X.�.X�E��6��qn%s)T��%{�b&�mUj[D�1J[m�\��V4Ļ��v�d�9eZ4�q*��*"+���>$,E��Յe���O��iu��krpn��X��t�C��0�0����PRķ�F�j� �E�fQ��e0�ِ������z���G;��{��q���ǳJ�Mz�:�ԃ����C׺[l����ͳbm&��Q��p9uV�N���j(��/�ϙP-U���{�wE,[����\onZgD	�K�l2�sͪp�N�[��s���b6&ŵ[R� ��J�BT�f��EU������L@�J��H�L�bL��11�}����$=O���)R���������e׫EU˖�317�f���+����'\��Pt��>����b6-�����^%<euΩ������7.�U�C��9zu}�����n.צ�n�a�[h��Y�a�ۋ�*y��Y��ŕ�57n�����fwq�Cl��-�n8%��y��T]J����9{��wne|�c]��Kӎq����.�q-����oW��뗮�ݱ�����N�V�b��k�ق)�צ�V���eE}����������s\�uS�ͧ�ik*(�F����
��J=�U�Tc�B�ݵSr�֞϶�ֶ�3��.[��u�Y��TD�h����(�#���T��]o��Y�-�+����U��zt㫕x�_j]K�-�R�[击���N�oW߫6ݽf���ɗu6��*���KZ[�-;�9(�3AS�'������fJZ��Zާ�����ڗ���$��d������x��I��%u����J�鮙���.)�[[���-�D^�������%7�{�r�̉����u:,s�ŨR��֓�������"�!9����)r�M\�F�<��UN�eQ;t���I�
bm`����%�Z��fF�N\���뼃�rz��d��>�KsI���s;��[4�Uܾ�m�)�ֹ.D���]nﮚ�S9Ktͽ�����:n��u�ܙw#�N��9NM򨩭�9gEV�g���Tn8m�~�T��}�:��Mi����aXFB�9Ώ[��'I���?R+�¦�#4ĪK	�=fV�)4Iť7���e�Ȳb;]-���y�VWn:\>�_0+�0�k}qJE��雅m&"�t�f3�u�d�v����t�%�hu3�~�A5�R�,7t磛(��f�u�e1�1��7�ݹ��n'�GQ��[�Y��3nQ���+��:e������H��]뉖֭�|[F� �:�+k{4y�*�l�Wvu�T�.��{"�G2ӽ	I�S[7�Z�ʙвV����O��<7H.�ɍt�׽�s�u����)���\��Z/"-Q�4bq+��^!s���#��������:&?���5���w���]7�����}^���L֫���"�D����Y"��f�Yt�`�������	_���x�U��=������j�g0�5
j�~�+cW�F�j�����|}֓�Kc5�Q�7|���y�}��9Ŧ�L���慗}6W�N
�����S�����ST5g�|���������U�U��Է<��i�T��X�a���u��p�=�6��9�[���!�_vk"}����T��>1�Y�y����>NG��γ'�oU:��7K�vɏ������}_����ޭs�kV���8�v?����e�&�Q?
������F�6o�Ǔ�?�B���9��C�ӆ�2y���Kmf`s��15k�uy�D�����{Q�����K�[."���y��x���I���s�!4�5�[�n���c�����)���5����-M�n~wV���k׆�8�q�������C��4�y�LT�[��bB�B1����k8F��B���;;��&?S��ά�7�E�(ǧ�4�*�z]�$y�Z��b��>~��|C'�w��Q�3l�K����Fʔ�L��H��1���Nc�:Od��B����B������kæ�������kF�hOxW�Y��h�Wo�e?��2�k�왵�Ϸ��,��K�|{��'��~�����o�쬍�e�������m�}S8k���dm��Y���3%�-o6GD2ۛu�8`��үb�(J4��Ȇ+R�%���I���j�O�����O]��Os;H��Fsg���i������K"R��Hyv�Q�����cgm���OE��:�3��_g���NL��M*�}ÿ,�5���w�d9��夐�\��ilB�+�v����w�q��K,��pr��ػ�sd���Κ��Չ;�����H�{�Iuomb�ק��=���D�� ��St�p{�N�a3���ݩ6�W�R�[�O\�ٮ�f��ɹe��D���'�nn�N{3,��k\m����v��j����.R�紌���'`�給�ʔ3q/��0�J�[��[����/�)9֊��NI���;�����)�$4D��J�[Utݔ�Kg\�*�sK1W��pM�����g�Z�� �]5�n���o:��#����mx�Y�b��S:j���f��R��o���;�o��̟)(���hN�f]�n��pOe�L� �w���ev�I�Nd���L5��t��!*��/�:��򗲊{�[:��v����)s��)�E�w��>.�[�<��&�CI�U�	U(�Qᳺ��t�{�ԁ�1�a0C�����
"
,~Ʉ��-!���b
1����P� ,��1!�X�VE��ŀēZ�vZV9�d�J�mX�H�C˪�Vե��(�T@%�b"��t���?h�����d��%P�Z{�������4&+��Lb8Z��4{J�`*WӪqK.!�cI��� f4�抆�P�v�8�2`2��H�O�`��* `7F�PHPy�����@3 "�*H6�F�uBIP�:�&�B�Or�2�Pd��
�y�!��1��]���E�HV�e 6E�/)m	�BK u��\����Z�W�u�8���e+�]d�*���mz6D��n�af0F�@�	���v(��E�&�� S���2�0�@����� 5�LH����rl�0�}A:Ŝx���gS�O������ D',5!���و;e�k\�E]��b�MI/��1�}}s�2!(J���s兪��� 	��	%k��a`��Qb��b�p"0R�T�Z�L��|�k]�VŲ؇�D�����g�� �%kV��Y���|�>��W��%���@��ě�%�[e�}�!(T@R�x�@i�K La ����
��J�k {��c]�lSS�,�e�_�H̙�C�r��0�30m�>��\`8�at>�R',���:�Ll�� ��$��':~H(����+'�;i��vXM^�I1�'$bX�^-�, T�҇x�P:��D:��Y�,]!<%%d}�v��X�*�f�紩��+B�<HB��Qn�CM�*RD��>Er���z8`������S\���JG>�M�9�?��>�,Ħ�����>3�`�2o�U��=d��n;�"�T(�,D� H�W:ÿ�����}ޖ�'S�59��jN�J]��`�vEˤ�bG��V��UZZIbl���
Ý���0w^BK u�g����`�
(�� X}�}�a��Q�j;���o�u��]#8��TtjdrR�λ��=Eg��8e�$�^�t"��N�ja���[W�*�O�9J��d�T�[�9�jژT�`u 2�=�HIul��2'(H�Wx4
��i�T������T%�`Ob$vɺ�� kq�2}ԯ����L��� �!O�T��@�"@*�(b�%���F1U"I;`��H��D�EE<苨T������QF���q�X�c�&��!�����*S��
h�lzd��'���6 (2�T�Ʌ kbŌ~P;�	7l�-�AHCP���#H�<TκU��M�յu��^�E�AB��7%XE`��h$HbA���v�{���'um�G*�$����R<E�������EΌa4�n�y�2�|ۮ����v�����F���{n{�Mv������ n��I�?}D1E�E�X0TEE���-b�ke���EER��UƂ�,��"�ʬJ�(��X����ET���II0��Ab����X�m
�R���EV#(0@UX���!
E�QV1A��V"1E��Q��DU�$!��pPb,b(��AU�(���TDTDF1D1���Q�(�
�FAb�X�V"(�(�UAb"��E����(�Q����UT("��X���ł��PH�b�D�DX���)$eb
*�XŌD"�UEPb���A�Ȩ�"�Qb1Q�V��
**"����+EE�b�D+aaAcU*(�b�U���F(�,ͭl�ʗ�%jR����PX�d� X��Ab�X��"AI��H�0X) �#H��`�*����llٴ����jTd��I)TE��QFEb(,U"�cF*�
�Ȣ(�Xj�Vl�6KkO�QADF,Q������B5EYR��cAV���Zkfֲͬ��"�*�b#� 6�QA�B4�Z�,��J��D�P`�EU�1cKDY` ��UEJYET(JTT��рu f�X�!bUX���1X�*1��"
2�	j*�(�EDUUTcX1F*"�F1�(,ADbDV"��

����,U���*�E����b�*��D1Qې{~^䢮��W|T��� �V�V�چ��M%\�Sj��*ڊY�dZ*֊ږ�[Ej5bЪ�"�R���mQ�`�u�KO71A@� ���I�0�b���j/����M�?g���<>j:�'�ug���5U�,�.NNN8������@@D�P
d�q���a�\&W!ɧ)�WZ�$�3����33o����L���2����(�RRR
A �%���S��6ff$�Y\Vg�r�ˊ�����.s,�efe\�8⸫\��+M6����8ۃ�89NS3,�9S*�S���NZ��+J䜇!��ߢ��Γ�r�r�̬�MMST�.-4�LZ��C����:UjuL��ML�)ơ\+���t�K%��r����\g�Z֜Wq�f���u���GWB�St*�S�H�*�s�$q�qs�j���T�t�.9�������㎇i��k���C�-kM893��2��8�3���8JⳊ��\��Y�V�r.�����	E\9U<��;��UYT�b�T�����KD�ZV+(�3ZQ�����������D-�H���Ty�(���ԗ��a��;�+�W�+����+��Z�����U�KeR����TnpR�ڨ;J*҉����Q���QWK�C�IE\�^|�u+�q]�(�U�����g��_���cr��W@��UU[��?�s�[�w3��l���Z1�e
���z�}�Ȁ������
!��7�������3��q���_����&�0& ~��V�}�|����s��v9~[��7�2��ϕ��|�w��>o�mӌ�V�-�BA���$$=>�^7��X���ν�~��Ç�������[%?��p�*�q������t��a���i�*ҫ�e�}g���i�oE0�ٗ����ɺ�9���������c�z��Ͳzn�_|���u������o�9ׯ��|���O5����:��k���|;p�c}/����I�A�$�,��L'��?�JK�F��Zr��#������s�i����;+˻��X�k�毫��;a�"�w�-��\�,T$��b�z�q���9���}��j���o�a���ơ��]��jZ�EI���;���59�{���o���|�b�P��� ���k]��7�KXHC͆4��0[�q�����Bi�`�"�]�.�Ua��s��b�o�1�H`�Jm�Ԍ��#b�����kgf%��24a����3уX���k2����>�\G8D��:a�,�U!s����u~^S?���/=�9�>��z�;��u���O�l�D� 46B��������Y��!F�ts2�w����A�a���M�uډi��V�3sŋ���a�ڹ�����{��72ʚ�?�?��Ը0Z/��(�/������st���h���r��2�� j����~��Y{Q�_�Q�ҟ����$��o���gF�i��h���ui�ǆ9㺞=߫����WtY|����	�y�m������z�"��������B1k/��O��~qF�+:~��G��4���F-_����/���^�G�?D��3�~����0 �l?����[���<����s�3�P[��|2Oﺀ׼���Kn����	QCO�/���/gV��_>���vӨ-5�U�-�3�-yߌz���O��t�3n�{/;��:����:NX��C�'�u5���=eh=�cjU����D�a#��m��x�����|9�^ ���;p����V2m��R}��t�b?��O3��?o�~53-���j~m��������º��F��~�f�YE�����z�����~?��<7ɜ��~��A@�yC�������⊾�W���mkڭht,$d�������~�?:������מ��^��32�3�u�W�0�Dt�K^(Y��c�XJ�6nd���t�M�����R����X@Ā�P�"A@m+kjk6�m6�h�3��ˑ��� ��Sh�����)̶��mm-h��V�تlR�@` �L�5�\֎��Y�aR%�iX�$"�]]���E�9vX���mR�������f�eV�$M��Js�id*
̺��a	��S	wt�R������zzd�@�tΕ ����a�"-C\�M۫�Y�SU�z8v�������C���!��*�.��^��M�Qm*a��Y��-W��xC;�DYU0�Д�L�n� ��iT*����"ԥ�٥5���Z48sPjfv��A��e���j��� 58�QQMiV�.�s�v�@ŝ3
8�w��[��r�.���ɢ��ܓ"ݝ���ݙ��-�E��R(E0�V�q,���"��nBB=<%,\Q�ص�4G:I�F���)k-�h�5��Ku�g	L�b]����%d�)ݐ�h��6��nƱksQ�((�r��&�-;<�š̄zj��mLQn����;�:Kw�T�3J�.*m,�bL��d�Y�.�H�sb�9X��u����T�;�*���9ݵ�B2DDA���D�
C8�{V;XE��c�9w�L-���n��,J(�fhx8t`oj&�d DO-16t��h􁪪��b�m�Aܹɺ*�[�;��$:�[U�Ak&���+b�̝Z���ʝ�nE�K�ܘզ�Qʹ8�Z��cF1rwL�tf�L�A%%Վ�DX�`Ȇ��������\1MR�U*��K��=�����7��H-�L4�ө�Ӛ)˃����FTg��-��"֝�&eC%��f:�TCi�-,l�.q�lY�*ቕ�@RiF�6I���
��=Ê�������DMM{y��5��v�;�uS9��Vzh����zyDZz��%�F�qN����Z�,�9�YF�tj��J�T�,�fj��6��D<U�ۊ��&*ģ;��RLEE��gxX�+:6{�4�����U�0f�Ip�P�j�tj�Q.%�sCgv���dh�v���p��m,��o��a)��jY� JX5��Jw�$����SM�H�s���P���.V���R��;ًG�st�fZ5�D��q"mP<�īI$٢ѝ��](�w{*d�s��f�'PZ;�IЊu,�	j�+16�Ȑ�vh�tN,<Ċh�r��j�8�XK�i���05 E:7��W��� �1��_=��ٍ���Ng(�C�eXL~m�'��a���َ��X@��|_4Y�ɏ�q�,KMy��+�\�'��¶9�bST���G']��|���c���i~x[g�7�?^�]�_��O6���	Uѩ�?VYt�����OOgs0~�������>Vĕ#lպk��j�=�@���
������Y��2�9x_Ǖ;l�go�sj�Ű��˟�������XA��k�����kh���$2������|}�>1���������@?���E�����?-��I��uz\~��������Y��>T�9�N4r���8!� �oͩ�*UP��C�B��l���,*�px#��D0��@��-��� `�1�Sf�b�`����Rt0�K֮����Zڵ�6� ��N���;r8]$&B�P��	xO
�z�K��*��֒8�L`4hb\��~ԟq��(�ԝTb~�(;����J�A���C$���|x�{�~�H��ğ����A.���qS�(0������>��V�ڪ��ڪ�ȱNa��~��s�����W�Fp��h�~,=�>f~��;?Q�~�P��C�����Ȟ��EUS�C�N�Z�E>��	�l�)�z���I�̧R.Hz�=��m��D��?	��_�>����\�����dʬAE[h(���y�� ^�O�%��a�s,9c����jyT&g�`Y����]M�#��Ŀ�`Q�,X�Ą�9��*MM����~�U�i��7�|�X�M���M;�y���:��KUU_A𪪰9:����KԒI$�E'�����
G1�d�������p��Ƿ�����!.���<C������?��!Ɋ�����ZֵX�&���B�ֵ���>G�~~�OJ���w�mj��#�����R���2ʯ���\���]���Dv���'�q�fhm|x��y�fϑ��������{����<:���P�����h����nffe*�F�U\(G3�F��-Ri$z�͗���y�	�v�M�1�$|�Wq�8w�v��߰�����gA�{���S��(�jI �I�H�����������t�χ��/���߷O���l߮z��x����lnfrzʟ�9ݫ�nu���;�dF̊ņh�7�f�Jw]�3נ�� c调�(��Ɲ���^�|:����Ka����|���	�ʊ">'�~���<��:�._6b�'h;�uӏ�o���#�<���u�����?�R���[?����^��&';T�|e.��j}���Ž��\�^r-�׍�kx���M��=���[e��o�ukn��-<KL_q���������AE�U"
E �d�
(�
A@""�cU$X(�P�E �,Ud�'Ǿs�������u���ί�ѳ~�48�Ǆ�����>�0=^����_W��?N8��M��&[���yШ��{�`us��n6 ��>��Ma�렦�xW�Q2�Z}�����a�:k��Éw��`}�T�D��~s���>�p���1']5,4g�����{����H��EԪ��U�TDq^$�,!`C�������#�,Py��?���Ⲷ[-��Ҵ�MM���٥�-���kf ��,�?�V[��?0�!�.<6�gT]� f��ϫ^'OY>��{_;����0�y�m:�3��Ш�(��mŹ%*\�3�2���dcSGEEC53�Q���v��vxUew���u��כ��ᵸ�yݝ<�.�])����ι��뙁뫵܍^��x�ff鏚�R�e�1�J;�:�Cǳ����r�r[��n�V����N��ǒ�����0_]uG5f���z�~�K���(��3:m��o!�<���2*���a�z/}��S���0�Nu��9N%8ӱ�<��w9�����ɺ3&p�s'g�z�~,��֔�'O3�'E���9���S�Y
��:���-U@�2 U
�P�����L�M��C�1���\˳��3����ά�h�(n�UYM�T��ݝ=u��3\�����k�	�]YNX�Q�#2b!&	M��J�Ҩ�:U������f&�\9�Q���Iw�Gfq�O30��sJ����&:��RM�Z�=��C��P��Z�(�cTD(EPʊ�g��ʦ!�e�D+;Y����1h�n��YՔ�L��i'O]up�em�:n�����5Ɖ�]���"�R�9��#���p�u�iM{=e�y{�z����G�W�/gt�/Y*��l�hK$˺Ls'5©9��BMk��˛C��n���	ݏp/V�ט]��x�p��n^H�<&��xr>�W��ρ��%�?>�Z3����}�c�����6���[��g�����s��Zq�糣��.{|�>����Gt�燤���m�힏�N2��:_<'ɯ=�1���wNفGUt��2���z�'��B����Q^�E�7�r�o'�'H���b�(zi�؛C�LA��M�w���ԯGS˵zS�����Q��/�O�sa�z�;�H���@2K& d�3Z	�b�y%$ h�L�K!CL�d�3�A�w(tB��.�s�:�(z�@ﰲd,�K�L�JLC1"d��� ��& b�@�4R�%�%�$� @���)�K	$�_4�,���hh��D�Pf�\(1�H�K�FY�f��=��q0�C��)6��+���������G&���.hd\�v�i��š��.�@�E�cpC��!�1Ŏ84:4���������Ѭ�\)Ŏm�,9�ksn�6]H+U�������kk��$`^��$��k�m.P���I�(���\����0�S	ם��70X�$�#"D�Q�V�X����Q';�V�bێ60��C&@4��r-3<�t��w/�Zfx�d��2!�H$c9�N�!ALL�b\"���KVA�66��3��{�;�}��L<��h�!���$4U;�٫��K[�GW����B�c�Zz�@�h 3�M0�m룝�{)���K<��w��ve,\���bL�n�T���R�Z]��Z�2;��e1!�T�	�U�b�j���ґ�ڵB��@���9J�E����p����lq2%��X�SUE��gW�^��˾�1Z����y��̧rzH���"+G4�tH��R(�#$d�=�d&X8�,��i�ͳN7�٤*F$�
F�c�������}�5����+���x7B#��d��2��RS"D��ڱ�d�'Q$���7�&S;);��γ�/]u�u�u���bHt�Q��a�
X��)(`[(�< )�8���ø��eb�� L��u�`�2��!C�K4ȩ��T�V����X���d��&��f�A2I�p�� �i<:����_[����[iRʕ�)�������P��2���V�����Ko-�bŗ�U��G3�%�-Z���-�ER�m��inbfecV%�[�4��B�E-[JЪ�l�Rʕm���K��Z���<�u��;u
=i�A�N�V"�������z}fx��p	ѳ�����m0����g�r��mB�_T�l5��;H�Yn��e�Z��V�e�R�k-�[KF�-��ZT����j����K[V�JbfF��ZZ�KKj-�m[ Uk
ڬj�Dh�KBҕm�Kdh����|����fe*ؖ�-`���kF�իmZ�γJ5���F��mm�t��F�m��lm���F�iiU-e��h����֗.!�KDKm��������Z�Z��[�qt��̾��"-�������m[[l�2��-0��`���EF(������A��IA���#��i��l��L���	��D�%���L �](2 � ���`�4�HQ�GhEz��DV�! `(�H�3LCL�,@�"i�h�1M,SD�-`�D�.�Y)�4ΰ��VZ.���@���i�I�`�H%�e�fY*�b���0CD).�A�RY
�<\X�r�P����X��qź�96l���o�v�n..M۸����q9z=���ÏFg]+-V�ei������).�z�]��W��rHs.�p2K���RXA	��zC%ך��^��5�+�C�@�	�O:<��oA�맫�}x��Z�����!�e\����D$���Tp�2��J�Sz�Bl�'�ѽi�B��(@Ř�(u(�usu)n���$�*\ EHgf'�֠��nfn)-�Z�*�EK�vVcHs�,�
 鑈EET�Q
�@@" �
�W�$(TLLL,Z�wcx�(P��htbc��3}=CC�݆fd3N�,!R�cF�$��&�!Ɍl0)a�&F3��QK���-)JJ�a��
[��,�� �m��m�X�#*��K (DL'A$����̃��rd�t��4(`������r�c��8�|9�n��D�#��d�s2�2�90�Ӊq���i-32��ДbF� �̞��L!3���5�33Τ$C��&��ez�j�ypv����ȰBâa԰2I�"�a��G��ZF&&��ɪ\CԷ��6d�ɏF�[n��,FC�0A�͛4 ��2ۡ���2I�F�H 0��1�I"�rP�3Ul� 	"�B�X^N��z n����n�I�9 �JF t@B��B0:4'l�&L	�b��Ύ�6!�i|0ɒP]2���tn��\҇��l��hg}g��V2�#�C!��`d;δC��y�����Y�D1L�[9�g�1q��-g$�(2!�mt�.L\�%��n�`����A�Y��37(��6M�cp��NC�M7pn��ɻf�NNQ�RΧ]#e d	ȕx G&"% ( , $��(Q����s�sw�ÿ]��N*ь�(g]OG4�B�IYq0���Y"�ZQ*-BK�X{zF�g[{�6;C{�6P��a�� Q��Xhd,0�!a�aY��Uyyw+��s�VK%^�ek+E�h�^�W~<�up��Е��w��9�p�d$a�& �1]��
얰UBÄґ��B��t>r��8oVvr�s��7���I�I�A�,�#9:&L�a2fa��W]��l�,���\�ܻ<S@�3&FN�(	�s�	I��S[���º���e�˒�lBd%%,�"�R
��3�vͶ�;�����́ �7
d�$ l�t�:dRi�l6�2;�u<�08�f�� �y�A��!�:���f	�M��	1s9��4ᣋNm8�Y�����pqB1�CF�cpJ�F�G��OWr�K�&�Y� vS`�\ ��X9�S(7��"��Es#@�C������j��am�i-���B���ݴ���@--�(#�t��S&����w!ͼˎe�4 a)ĆC���ĺ]��%���At����!Vs�gg9�j�XuaaXXv�a��i��@$J(��0 �E]D�U&N�w6Y��U�&΂Ydf@� LY�2�e��6פ��D�D�b�C{�aC��p��pCa���oy�Ti�ͬ�Qɧ!�M8Xn���ŃM��7Q���4EKY���f�, P!BC��k���iup���?u��e9.f���fux���w�G}��^5Y���whXfn���wC`��l�OSg%�Ή�@�A˧\��8s�s�9�q���A�'s�!��s2�z��<�1#1&M�n�0��:�Pѫ�%D�:�dFlAU�� !f�d���;� %�l���#�uA@�m��B��nvS����;�M��d�9a=����a��g�̔l�q�bT��]��
E��Q4t�C�Ԏ��2!;��A�N2�476hh3��6z$�$u���ݺq��k!2@,�#�K��n7�+
ж@�́��4��"Ŏ�h\���a��YfD�s0���33õ�Wm6�k)ҝ�ҫ3h�9,BP��A�������\���Sf�$ �N@��":�$�Id��^�ӣ<�����v�P谰�n���b1�y9�e%�6i���0��	�CC-C-�$�Bd �JR i�#��@�`�
l�%U������NSg-Oa�e���
���jl�l�))��3Ll�n��0J���e��^.��3��'	z: Cfz��Q���-�nfg`�
��JK<rڡ!�4$���yl-�ɒ�F�S!qu5�������wqŵm"���VA���C�����m�JM �RY,7j�t��������ӎ�1c� pgyәN��teն��(r0*\esUƫ5:M�m��RԌ�2 �B�[K���kB���vF���% ^�B�`�r's�2l��:Cs:�fۭݹ��@��B2J��BRl�&�� �d�p#.��F�p�#r(�q<=5X�{ǹ�ߎ-�t�C�0��wd?�~�{{�U@s����M�����-�<åPb�-���3�ϫ�cP�:!�?}�ߛm���x�;��~3�i�\�C�:D�Ā�No�\S'Zt҃9ǯ�\�Ә�#�WTv�̮T�d���,c��_q����������:`U�Qq�
�[nj�� {#�n}J�ۈ�s�Q�����\��/D��Ň�o/~�d+���k��,���c���r��aU��K�<�w����k�dL�)�ޯ9��UDMK�b0P�l+%`<��Db�ċ̤zK��1:BO:�������N�n�pR�P�y�vu�s�ν����OH��$�d��rʒmhe�f�-�q�&2���d�� ����\aQa�I�nVn�A`b]���k1��Q��0J��9���"ʚ$��I�!�s��af0��KCʀbbJ�1���đb������L��KlԨ�Ω�Vä1��u�R�DX�׉��N �ѕ�D1��Lq��j��#-��-sp���pV��`�S�/�����Ī����q|ǣ	��?s�=�_�np?2��\�yz-�<�.X�����c�d�:u\C׍�ۍ���- -����Ϭ��� Aх{�B�08.0G�A`@�*��@})����O��� '���T �o��*���&�T��ʃ|�x�J07�i�>1�`A;7�5�4-�j?������>���HQ�VKJ�Sb6T���ʭ���ڦYT�[Te����*�J�i�+4��Y��c���pWL'����r�a�kfkm����E#b��b(�#UUDF
�b+b�PFٲ�X�U����ƥ���Ĩ�m[*[*-�M���33dPD�ms�����(�GGq�4�o��*>��}\���u��mt�Lky��^a�E7'y<���[\�MB:	1���Νm��Jn7�j�LD>4ى�� @  � `���(�HEl��D#�X�4��ƒ��f��i5kkR�ll�%kb2��eW4d�7�.i>iu4��ӎ�M�mM���ʭ8�M4�l�*-����Dd�	Aa҅E
�T%6,�0�@%���J�m�3���ҵ+�F�@��PUU�	Td���Z9�3[J�4f���m6ʶM�����1[k*٘����٘����o�\E[l�U�Z��a��ʥ�d��-mM"�K
�YU�uW5�*�[Rl�Y�a\is@""��� `��A�����ޤ��e N���_�}��E���0F�p�����Z+��	(j��A�\�=,B�0;��E��&�&�%���n�Q��ҝզmP�-��۬�ڣЫ&V�r��n��v��.��Ze�G��V&�:c �A]��@��`�[>�6����ٷfF�����onz�^�,�$�@�@�$a	��:A�'�`Y,��	1�� k�B�"�Ì��@��$3-d�� 	$����G �0a�@�jճ�+�,��L;�fw2U���lVZk6��jٳj�kekO���fgN�ٞi���ViY,ڍ����y�j�3��\q�q���NWou;'��tNY��<�/�pqƁ�P"�l���`)��x��333.�38�8̺���t�S�(���0�!Á���������JD�p8l��)),�L �IIe,��,��%�b%���� Hh�w���2�"�!�H �A$��I�a
*N�l��zJ�<S�֕����\fqǁ�7*k:)�t</�qq]�Z�K�uN�:��:�q�ruL�ҵV���W���D+dR!�`���2��)^]\��Κr�Z��������\�Xֵ��x�')��5�r�$����DA�m�e��948��rqU�t�:N�Ut:�t�t���ar�.ݝI��:q�H�wxkZ��0��E�:t�:Wj]���;]R��U:����\k��.��o
��.Iq�gJ㎩�;�鋼R�Aj
	���\��\��9�-�+l�ί�:��n�.9����O���G뷛�?�����u�v�]���γ�����5ѽ��|��u�;_B��O���da�b�+��g���څ�~u�c��L�հC�_-�[Q3���Q����;�fZi�W�%A���[+_��%��;�~��~my�UKZѿ<|�h�V�L�ܻ~���{#;o%ٍ�Z���7u�G,��=c$�Jz!p��lN�i�+~s�z1�����d���+g���V��w���~ּ����m�k��dUɾ�-kKox�����H�i��F���U�ɚS}��~xc�c� �=��������sR�t֪�RGlc���x:~���f笌�}��iS����cT��>�S������ڙ0L(�x�gkf^�˶�tN�qM
�ԢS�TϚ����ug�U�;,u#4�*i�"eN���a���cΞ� ����t��3��U�<TC���NS�J�e1�Q�����4�3��b'�ݶ$_���W��[�o��:��C��.M*���2���:̚�,³"�'�C��`�0���p���?t�I���G����k���#����k�ק�S��E6D��V��T��B��^����0V�:	H����N�����M�e�B��o��Z\#x�]B��*���%�J7t��=�H:�4��p��L�K2u��=��W��P'5���?��\�z�l��j�.4��Lކ&c��M�l����1�x8�g;!��i9�N���i��q&�<���k�����%/KM�^c.��}�ܗ+��z��^�{Jq����g�B�����<<b��0ai��h�ōKM�P�$�G�xmz���u����Rs�7AT����ټ�JEg�`3��	�x�ܚL��w��π�# 5�FT����D���&Z̸��C�R��=��S\Ņ�)=���r�"S򧐫�L����=�|Cn?ŗ�xor%��/��r-��N*��ʾ�'��v�L���-�y[�����p���b+(]����b��;�\޳�ԕ���/��kf=�n)�ebe�A�3݃�;�����tt���·��)��"7DMe+5�9|+�Z�C�?��΋���\V3cG�9k�`�ܜP	� ���4M����}��K�heVM�� �pg�B̑)p��]�v`1�n����fm�����@M>��Q�j�Cް��5��J������7�y��^bY�=���r��S�=�x�B�(R��\m\B����Hj���}D�����w��𰦛��[�O � �]�5�rm{*o6�4�)��u��l���}����_#=���b����-����w �A������멞�>AWZ\`]�N.��A~ ��3�����F�V
��KD������L��z�[h*s�4G�C��>>�l����N��S%%j[��&P��<<����Y������V�91��;ꬱkav�>}^�W����s��3b9���c�z�uLa�ß���w1�A���(�Pt/D=A�f���G�S�J��W�SĔ���w,&�̔sp�|b�L�ZJq2��ݲ3;R�b=]*M�.����Y�Z����M�ApS�'9�]jˉeor�!\�Z�>e2��Yg���ی����{��K�Y�NC<�{��wm�h����NN�x��i�t�5��?"�Lf���wW��u/c����u!g���9h@4 ��3��q���ϭoyU�i�E���������_ DR�֌4�t`d0�i*V��R��O/Ԛ�{c������Xn܇�}��#R�{�����|ݕ��F�i9cX���&���w���3g߹����AZ�{)��޺�fDe
�af��$*%y!��g};�ǰ~��yX9��X������zm:��?u"d�B`1�SV��
�0[;zY<�T�1آ��K�)i�M�J�:NU��S�d�i��g^�|蒧f�\��G��@�c!�	Cَ(��v�g2,�pr����y�~��l���s�έ����ɋH�6���+lv��F@�cw<��ݼZ�ź� � �`�$6鱥'V��?�H��ƛ*��0���-XG�^Έ���ra0(u#���ԑ��z�˲%�]��c����}Zmp���>Ç�[����d�OZ �N��xw�V�y�P�*��
_er�QyU=�w��=H�7�>�Nd���>7�A����x]a���W�j��jU���l�b14�u7[��������J2�nf ]���	��F�tl�����MA׍w��Ik����x��'��Ii��4�<��rq���02��ѷ���>s�#Ͷy�<س;Ǟ$:�Ƶ�?j-S��
�먳�k0'���檯{��o�Rdj���l�AJ&2~r5�q��8���"�.@<��MT��="8���P�����os�������}3��I��3vB>�D�o����Q{Y��K�F [a��2��7h�+��u�3м�����듪}W���7��r_V_�q�_='Dצ}^��[9��#���gf*�t��C"�B((k���2;jo��rnO�αy�i׶�)Hs���"��?ұ�lv��4�/�ʡz���8��BG8��L��WT9��/��Y\	��c�$P2!��M YD�zf���>oP�!��&0Jd��Դ���Kq��:܌j�����<Vjs�H���S"���,� �=\��_����7���i񭤠��g?E���_:�m|t;͌���'��QA�=���i��h"�#�U��g|1}�351�2�ū}�Ng�Mf�M22��{�1��B �G��f��L��)@�)�&�����|�!�1軞~?��R������m@�
9>���W��K�)H���m���	l���ж�y����?���;]�{�!��晵s��`�#[�\5a�o��0 �(�$s��P��_���I���������A�J�|V_���y���/X�k�7�#��Naq�N�,��6D8FE�����N&s��o%���^u�|Ю�8�o��GW9��{�/o}�ɋ�j�;�tMp����Ķ��W���:���\�X�[�g�[N��H����.>l���)��`�/�Y#�p��o�RB�4�f�}7���bu��&6��|�1�W���>�3�aB��&N���C�i}}������Z9���� d:��s��ic��\r+z�G�ȝU���c�ӿn�v���g�K^۞d��<[��H��Qv{�nR�Y��gz(o�Oy)I�&�F�ƞuq<�Uy������\n�] ���f����vE�O�l��������c5��'u��k��ː�\J���f�î�7��1X��w�.�4�ϲ=.�U3s�MɃ��<H�H�y��K���y�]�i��q�߷��<�b�srm�E�k��1��B�rSk��&>���ǳ=�q��;�G�ρ�|�̒7��*�pYr���d�
	��k2�E�f�	V����������}�{FA~���rߨ�#8[��7�<������������;χ��j��E��e� ���B�Gz�v�XX~�I�&rC�3X���#q�J��}��"���45U�	��w�K��`UC>���Ӹ6�ww�>Mk�)((�T�⎊�l돻/F����}.��Q�;y����+��Y}7�+�q�Y�┟-t������,O�������[:g���ݖȸ�?����� �?>~������Uo�4���>�E��i����mu H��L��"�]���9H�#��8 ��5f��L?^l�o�Ǐ�ʎZ�}xדjfS<�֝a�V�P�` FQKD7�
����3�lݦ��ڞ*���) ���`8��xN,�σ\�^�����3u%�b��~�Ŭ-��>v?�y�u1���U���O8d�;n~��W��'w٪��<El��L��q^�[��	p�>�/g�q@���oM+���н)���sv�X����;)���%��C�4+����h!�a�$��pgS���G�#�F�"ܔ���a����\
d��~A�f�Љ}1�;_cS���t��͘�O��,��O^�ؑ�>�|%m�mr=�7EF���+P��9Qk�Y974=�[die�:ߢC)׭g�S��H(_��xW0"�����_y��ylG�ϞyW��c_|���#`L
���;��T�}� �\�GC߻�����d���#x�F�kI��U��d�Kt��,s���\��'d�G[͌�TKT�[W04�X[��mS�G[o��,���0 �4@B ��R�%t+L���E3��#2�6��i�纎p�mɄ�D��[�C��ń�^���޾������-�����[�����\%�-�`cY�!6$+T�M)9�cf�T�U�(�r]��^�hN^����HȢ�G�ܮ��.Y�^w;��'b�z��ﺭK�;��0Y���^��D�".�;N�4�c��P	������z3Q�񺲐�g�=Lw�ovn�q�x���4�����F5Cٴ��f[Ü�0ҳ=������799��\iĝl��O+�Y;U��3D��V��f�H5$�@z9�h�2D#���_qv'#��>�϶��h���:�������/�]�����w��:�}5w���1��׷��I�A��l���M[v֗���֥�s��$���E��X�a��|wQ�uӄ25�qpj�I���gb�$7o/6��\]v�9-�D�|�E���4�!�n��1g=���tn�ͮ�%��7��z�Y��d�N �x�����kmn�R��ܦ���kJ�����I�u����0���w�����A�=1h[��f�C���W�9 ���Uw�I�5��c0�=�{Q��߱��7!"`sqƥ+Li�&�i�"�VY�{��"�g��"�[�OF=vI�`�O��0��
��Rs�g���e��E�ϲ�Ʀ{�}>�ժ��}�l��Y�1��N�p8zv�fj�|6
uj-ԭϛ,٫��	P����_*z�h��G|�K�ѓ?�ѵ�wz`6�0��;�/�f�Ro�jYs�[9��E�ڝ����{�Q���%�W?j�q�y�#J�{�UЇ��m�.-w}���J'(?}��.�N=Z�4]�B�4m�	G՘�ԏ-4��u[�"e�F��@y!3 Ԟ���jYW����/��(JR��6:���!�M	��yu��fϬ\�d�5���p��m���_�.���&VXްx��9��6TD�V�iۢ������ ��]ŋҪ�x+�g��[~͵8���cm#T� O�V�g���/D׍\uA��J��<���C�]�TZ2�}��2AC{�/G�i��@;RAS��By^=���:���~��T�>o��j�����1Z�S��#3��n��30�u�8��P����մJ�7�C�D]$=vUW\�K�Gy26��-�@q��s�o/���H=��_y���>����Ac>]v^e�Դ�-K�e�-Y3g�C^f��Q�
40�FpQ������O�t�J\��gN�/Ϋ�1�oӞ�������
�S��SR�QY��6Z��
�)�FpY������j}W��3�+�u3�)� ���~o^eE��^i�)s���}*W��n���;o�K��fR+O��ɵ��O���//v��=�;o�T����u�yj�C/HK��zk����ݏ!�
	���Ui�2aO���FV��F�,�l7]]ML�MSUf���)�T�4�����H퀯GOU��v�x���9�A�E����sO��p*�Q3C�=��	������n��h�	�h���sj��p��,r�2�wr��0��W��;XQN��O+30�w��u31ۼ ȄD�F�A1;0�;=>�l��y����{���˔��3�l"B�2H,�@$O�BO�a=�q	��������m��3�N$Ow�J��i���X��%�lD��-��ˋ�.K?n�RúW�W�R2F�!��g(1Qt�(��`�)�B͌�$)���ݳ«��]�wX;�S��Vb����^J�S���i��R����-����OE���.�^l<J�X���pz9i�˕-v�Y.�����xF���;v���C���WWl�N��K���t�OtY�l4�@��`�ɒ�d��ȸ�@�D�����mV9���gD�x��u:�C�r�:t�f��N�4���k�<R�y\���,��3-��s�y��t�pyr�FH���A��c,e$8p,�UU�TZ�c9$�!J@�R%�fpt����gcÕƶ��^Gu�	�����:�k�OYԬ�;�;��S�u8�4ӊ��3�.35uNW')�2��t�,�K,�)(���B�� ��x�Cկ����]�'Wfd,c0�d��YK,���c<.� \��XB�۷)�1#M4D
�!3e�PYc�� * �R�=EF��-�
� w�=�e�WG^��~FYʛ {���Nl�Y@� C�1@�$W��o>6[/�n������Ow����� �6C �P�'�ejMҺ�o&3Qk	���9��)_�B��������������t��U��T�mu�_S�F��S�1!J?�<�C��]�ZRA쥉SH��ݖ�����q��y�]_@�֍����2��uږ�.��E-줘64��!������
�hF녣���y@��\���3�����.)�v�G! �2����uQfط���3p3R���ۀ� m��r�]��1�3�Q��n��榶�o�iC1Rʹh��r�o�G���B�� ��|n3}�������&������R�"�&�<a<{�y3ȗWI�ף*�������v��$���W��
>������s����~O��y��$�����(��@��(}��j�y
iP�:�q�����8�R�����J@C�n�x�I'�������-K��!u�U-���G��H��_��dWg�3@�u9Iִ�|8��ϵϷ���߻%��"̎e��)���@���e�����4Ψ�8ͮ�� T�yˣ\�Y�n�t�9i$��ĲL�ٶ5j'}"�XƮ�{Ԇ|�R�����H�{�'�?2ė'Y/����>�`<�$ =��b�7�C!'3U��C�-�8AC �Ro����e�A�
e��@�4�Ώm:�F�bs@^޶ay���I� �4EKFMR���8\P6����T��㳘 �-�������7��@׃�8ڼ�����ڒmT�Mo�v�wO�F&r>Pǣ�Zqo���d���็��Կ�#��$������_V� ���d�ӾHg�4ZR��S��i^��f�=��Pz��&�/є�8V�b��}���>�MT���]��D��7OhlhTa������*ڥ�}ƨ�G��z �uW��ƺ��#�ˏ:�݊̃�{f��|����}u�g�)�{��R����'��isa>��϶V����z̔���'�M,�-/)�(XJ�6u���$f�9��>a$$)癪�]���*�n�B|�9�� `��جJ=u�?o�8P�}�iA�w��/l3�����S���?Q"X1P���),~J;�G0�D��&R��w�o ���#N�G���E���h)fK5���<k5�S[�.�yj��p(r�ɦ3�x���Z� )�h�NM,�\+C<��w��ɶ�4�r���ͼ4��5����x�>�c�m*}�fK������D��������|�!�bc�+�+�/����~=-����ϡLAsޫ\ �>+<�髊}��)�)3�PTH�˩�7D؅�{n<�]�9���l�r+~�5)v�5����w��8�d�+S=F�^-���M���Y���齥/�0�G�}���r5.�f�����ۿQz��1g�mWY����O�
���]����ɓ(����/u{x	D:HA�)�2S1í\�z���VMq�D���Gqz����w�����P�Ĺ}���i���2���J�$��!i��5��/���-�N��or��Ry��?V���.)�(�������c#~�.�����RHދ��R����ABʑ&�~�K�*;a���r�~/���x�۲5��V��s�ާ~
����d��W�Tڿ����OA���=�d�,? ��c��������\�mg����[i4��h�'��|��l���ܼ������^��}�_��|:iz�*�I�;:"�!+�o(9����[;�/Z�����qM��d��������~������G������D<N���A�@��%����������ל)i[���ֹ
��*��7̏2��+':��xj�K	wv����n��;���J�2\��;o}�u�jr��֛��˖9�?�(*⣣+��#K�vɆD��6�J�I�����S���qOÙ� e��U�9%�W�@X 戉���G�-���lI�z��j����C�|1��5sy��yl�Њ�w� @����QQ
��L�F��-.��h*�����d������8��>�\T�WS���1�_	)E�3�oK9l�C���<g'_���yʄ�"00F_=�=g({tc��Nd���!���O"�u�wO\A6��  c�������$:v�1��:v�W���"��P�k+��E�I�%��1�ѱXԽ1}�lN�P8D6�6Gq}�C�� �(o9\-�o��8kaCtX/(��
	�qX��8A� s�&�)E��$���mS'�#�*�_��jj]�+1֦͎�������kx��i�����G����߬g����vؚ6�Q�uJ���8��׊L]-��wm�D��%<�5�W��T�K\&���#�ˋ�[���`I�Y1�O���G��`���f����Qw���j�5�z��s��A�d���_P�dj{��<^�x���tȌ�� c[_�=��=���F�Ǖj���3"�L/�_ao�8����)2!$pv^�I���U�gh�x^�0/[�H%;y<��wJ�9gH�{�����>ǂp�6�W��MZ|bH^� #{��4Ƈ����k�3LC��֪��鍶U���X�P�V"{��DF@'�{8�|i�֡�_�M_�ƶ�)x<������ֱ�zp6l5�dp���%MЀUw6m`�y����A����'�!�T����M���F�&.9����6Ha�L�.��Q���2�F|�&�T��"q����>�d��asU��D�:M��5��\F �����P8��TA�&�~|���K�Ǉ��<�;M􋹽����хXk]�Sr��N2o�7��>@2 �:�q ��l��'י����A�k��R�"��V��u�9��a��0X���9H�����^f��q�o��s�\��b�c����?>K�H�,�.�����)�U��H��ݡP<�׸K���c���@��EV{����ԋjEX�6�!�� *-@{�nݺ{B���q�1b� 5�ƺ��]���{�e<:�d��^�a|ٽ�/�Z�1Zj�����[�����kB��NJ�&��!�դeqqn�*Pisr]	�e�|�׸����ɑ#F�s($�<�K�	��w�c�(�V��ZB��ů�%X��1�j���D"DW}6�.��yC�e�x���;	�cx+	�zE�6W��3z���vs����J�Hx�������3Gыن�t�����~�`0���_`ֻ˵���{=����e&mg߾�����3���V�l��2�{%�7ֽ�8��b&� ���s`�%��z�4,^��Ҥ9K��C�U��Ə���vm0#2Yc���+h����N[�7���V�,�^���p��ҥ��"�y�/�x�.M��e�f�=͹\¼��6����@ uܨ>Z�SU�u�|��!�"B]�E)C��Y ���Ϣm���[�����=A�"�/��<����_��dc���j����ﮦQ�i���h�}r����9U�#��je�oQ���	Y����B$�fD�]�k>��ۿ��;��ʴ} J,4.���ߑoF��՚Y|{�H���B|��}?BbM�ga��?�ȵ�ޭ��)�+�Srx&qCj�p�~b�
0����jy�n?�4F�Ըs���?kT��.����Ըǻ����Ծ6�>�d�@�Kԗ��G��R���-1эX����� ��+��䵜5�����@i���p���L���쀽�'=�.gQ�h�s�'0�w.���#�̈>�^�o�,Xh�q���5D#�1����x� �W���&�=�a����'"#�p������[�(gZr���$ "�m�hSh�{�įI�/Tu�������N٫�}0&2uB��>6�b��\�J�5�o��vk$fX0MnoH&L����d�9Z����%tH0�y�.(i�YC�,�Ȓ3��:^S���;������'�P�)���������ׇ��"	3Q�,'\,��k�P�_�]�u��+�-��Г�w���t�ʑ΄9���-��1�!�u?4����A[��1��8�n��Il���L9�螡��#>���;���$~�RX����?�� _
Y��7��Ws�r.�?rB-�h�����1���|[��̽���=���Q����)3]�;o�%Sl��{��'�~U��7�koЃ�]E!���1@ѳ�,d�����~������c�@u���i�mW��	L��~_j�d7er��`� \.��bXs�=��k��|1v���&ᖡ�a�{�e�[SH��6S��YL�kua� h1��_��@��0�X2�ݐP&����Y@	��f���K$�:�"")>E�Llp��d���D/q���z��m�R��'�\���L{��s]����m�X�ϗrW�`W�jt�㬑�6�,��3��cvG��Y���uw����-
y~��F{���u�C��{#^ü�~���'%�tu9\���͙���e9䯈W_k���4���+�c)=!-5��W��xFf2>|���2�tm=��Q���=�u y* j�#��%TS	���E�P���mj7��W�KϢ6��֒{��:��F��Ҳ� \z���(�}�!��.����+�۲2n�v�éꏜ�҂Lu��gR�2��Wc�ьl�o?N�?E�%B��n m5��[����r
C^߾T�;��wehV�v]�k�x��o������;�=3V�g�6���TS7�Ϋ�Qc.�Ũ�o�N������
C�'g�la��Ǫ~y����5��I���ؚ����	�bo��A�3���l��Hi�T��\��|�u4y�WaJ��oN�FR-A
��$��Ĺ�d�ЎOT	mvw���2�g��r�ٮN+�"ٹ�_����.~��l�q���v<�]�wc%�!� ���� �g�)p�)F��}�z!`����z]˿�3��Ct�;-��撆��k:_q=�����ƻ&?���A��T\F�>rd�e�[�ǣ�˦HN�?|9���aI�b�5v#��F��%7?E�:�8/R�Ё�y��/,f�$k���@Ҁ� ������� sॠ
�u��o�H��A� _���jy�g[�=T�p�}3�d�W�	�.i�,X���9l3~���J�p�ժ������g�`Ft_q���� ��Wm~��WUT�S�p�3��� Y1����@��8V5��O�U4 l����F��'F��__9tǷ����:�:����p��������we��Fm�L�h�n�����Ѡ��ǩ��J�t� Rm�N��������k�ژ:�0�=��N�
����KuԻ��^���C�B��Zq���@Ϋ�� �P��b��W����	����({�x�#�wz���Eoc���7��Os�g,��_�<Q�1.\{{׾��Z���Jg�;������%��-���`����I�-�\W[�ۚ��Qp�7d�=��nu9N�a��<,b��8�4ʙM�e=��w�R��0�[@˛|��7o�y"�)���"�V}�ZLKc~I�W�������N���@�W����$��?tf[ۺ� \����a�	���j��Ȇ�볝*֞)�=��[�2n���"�ݷ@�Y���.�?�v`,�}��W��>���)����֩����#>�|	MLzg8�5Θ��Q�o��������2ӟ��|��e�KyC3��G9<W�g;h�է;�D�����)?���s	��g�V��:��l:�N���-��z�2֡�G��޹��ޑɻXm@vL��{��˾
�'�V�t{C���i����=���Ս�<��)��as���[r��'���u��k��괠v�c/�y��e4��
���u���J�}w�����$�a���k/��y����2��.��4P6B7��z���^"���-GB��>��T�
FeC+y.���;%�i	�<�h�{N�K�7���7�����a
p�kw�sI��N��>�ީw5��K�r �f�=$���?Ev��R|$�ĝ!+
��8��@� -	����8
��ZW�������2\�� pz?�̀�+�0B�V���#�*��V��YősC���ŤթW2WT����l\s8�휲\i�T���*�)��a$�"~Fc��~�k��e�R��l������δ�7�R7�o5/���-���3�߄6�ڽQu�7fs�3�C<�md�yN�(3���t����` I��gZ���H������Fm+T�����x��.j�q55�	ʛ%�i�����l*��<<N� ��R֘=:��W�r�?��f�ᑤ$%�M,� d4v���r̪���a Y�%J�\������g0.n�Vj*X��.��K���R�)`�PU3�Ii��i�.��eZ�Mj$�f�fl��㈆�IEJ���R޻���,t�F�~��{�������˲���F��#��o��I�[Ya
�K@[R8�,������4���+�.V+�\�S��(M�,������1dX����!� X
D`��b��6������i\��0 ��A�;�H	�J!1*�j*�$�'��M�h��*��))Ul��P��,���̺��+f��+V�TԬ��)�Xt0�mF�l��Ҹ0�T�j�j�R�IN��/T`):�H���:�NL̬\ru.�U^6ںu\z��5��⪼]��#�݆�N�e�զY���̗H��4�J����r�u\gJ�j�X�V��t��J�v������-yK���`X@9m��a�d%���+Z�ӷl�*�ӣ��ɺ�絲�vR��t<��u%˃]o�<\��O3<Yj��T`]P�]G�d{xq�C`6���?�6<濽�j:f�Ũ�d<��W @�T����.5�d������սtq��,u斑�濶i�`
�{��OYB�<�	�����э(�OQ���S$\H�g4�D�Ng>ո5�KtS�iOً�X��^1g�F�1Zk:���"�6�뫲�_5Ϸ� s8�sG)� :e�j:�z��c/���]yoL�/R�[.|�L�w�=�.E,Ʋ��YI�$4 ��;Q�˺�F��,��X@�u@��DY�s_s�I<�;nXxc�Sל:w�!kA���`Z�;�{�I�|y�H �6Cbo)K��\Euꈸ�!�>wQ��q�&�
�2n�ӥ́2`����g#qM�ck��i�[����g�2���3���7N}Tyz
�NXuϧ�ċ�`l�y��w��<~�ނ��=��M���q���F>h������9�V49]و�'��b��4�y��8�:���M������t{CQ��m�Vr���ЉS9x9���?[O�9{?D�s�-����Z�Ɍ�9��H�o�#J��:78���+ow�I����	Xz��z�q����+����Οj*xG��ƺ�x��zN_5[����Fq��e�$��ϒϲ�+�E����������LR����Ľ�s�Qh��o^�7p��J���1׊�w��vH����a��s�}��`1O}��|S1��E{�+9ү<���`�ck����#lN.��{�G̴n��݉]�y]D&䄯� pfc(w�U:�F����Z8ܮI����t��{A�J�Į����s����"ѭ�)����N\�k9���s�s���0}��O�5�۶+y5��~Eo�Ҿ�s�¦��]�H�DOu�;�z	�^ڎ��n2�y���z\e,y9�� #m5U�Hl�n҈(��J�� q��wp�x��y��8�sj1e�&��L��엛�f��͜F�'�;R�_�b�����_C��.�C��5n7.2~a����ⵏ����a�����L�S���v~�kI�ۅ�D��;��e�z�* .|:�(.0��^�v��`}�9˴fK<rO�f��s�t�=݆�I0%��y�>uHxR:�:��=&�\���.������J�G��+�*���#h`F�߭/�ۇ�\���z�b�g�X�?���i��a���>&����o@Y����!1]���~~$Ő����u`�-)���Jx�;~�|�Nc����.�&�~��$XKARu��H�|
����י{��/�o�<�^����К���V���h��2�hK�}�\�KV�>�*�a��MM��A�+N��cB2��I�ƾ)�z�m�����zP�k4^����sS�38��ɣ�@"MP�r蘲\]B�O�l�N
S���}�^�� !N��TL(ɍ�$(`��.�oD*��/��i�Ōь�G��{�3_�}�}I���y
��+��W��:��؇Kl��D3�������U;Dz-��
)�ڙ���Zө�Ϳg��>}N�2ΔO�|.�����Y���L!a/m}��~L�����lk(��n�.ы��3 0���%�i5jP�8ϊ�ɵr��d`���z�>����n��+���(3�I�C9TFȗ�B��|�Rwͼ�O�4 �V#��{��<���-�aɋ�G���������ڷ�����O��CU�u����a���r_��@~&���#����������y���:?�b����vx�J����x�@x��H������&�mI�f���j[y����S�??���+q�}��,�X�x��k� �N��'\�p�){�j�>��蚛i�_���}g)����{cϐ��e5�I)�^����������ǵb�z��e[�;�)�f�|��u�����B�Ș�>lPC�2��kc�vLP;�k��f�S���P�Q+}�TZ�EN"ǋ<������'[|��qs�Z���^���o@ɒ���������5+��Ht�giz���W(��.�!�MI��������lv{�{z#.�?[g�e��t���Y�wG����A�sHح� s��NXƈr��?>q*�q��W�o���! �q���J<K_K뷵j�|W��l�s|y��w����*/-;���ԟe�y#h=3�2i���������xJ�c���5V�X�yu�'<k�j�+���M�����g��B2fS,�x_�<�I�`
�d����	��L�g�f=.w�E���j�����U~�= ���&S����]*��e���|�i�q<�D�ƛPH�iV��4���k:$-7r�L��F@Mu����e3=�T��p�]�Vc�����F�wZ&����}���CQ�����W~ 7�k�q��F�؋�w��܀��)�ę�1� `�7D|�t�M\E�0%!Z<��
t��z|�7]���$����̈́�P��T���g�6���������,P��������a���Z�K|� _jZ��6�Zz�z�V��sm�ԃkജ���.�x­_T�>A����a���C=8π?I��C��L��h�Y侻8��䫏���*��#?#���K[��f�����kY)�R�b��}|F�<p�y\E�fj`�P��\�4����Ԅӧ���<8���5e���h����g|��>t!Ѻ���כ��n�گ�%'4���%����uD�;�N�ɇS2�xMn���U�m�J��A�t ,e�dc�n��_zY���vJ\�f��.KЅV��I��.��V�CŽ���Q_WK|�o�a_AY���{Gi�?^d�ӍZ�G}��MJ(���Rk���S�	�7��t�+�;���@�w�� �o�_����#�?`|�"|��08�J�"���^���ܼ.��=>l��ckO�����g6�G�����������r3�7&���d��;�o~~�]y�8�BQ��W��o�OY���\D)5=�Wmޝ���%�פ:��sRW�3��QA�_�U��M��ܢT�1D�E��n�U���w�V]����~:u8�Z�����K�)_o��'��@Q�78�/� �V��t��ݑ�.{�Hn���
�ZUd��g?�����~oLr)ve�g��o��T_:c���?��Rw2ڑ�EKޅ@P�\�c��������rQ�U�?�{;Փ�y8�8ח8<��TY��z���3.�f�	��W'I�6x�G���|�����_�\.�q������e�21���DC�>�8�y+�*�|�;��Ac��_���M���G����Z��Ϟ���G�����}S�1���{�>8��"�b�/澇��r�m�(52�t�M�O�0f�v�]qQT�G��� �╖�6�����_먱����Z�<�%�f���������*��=_�<����
O���4��٩��~�=2t��u���*j��*�5[����4����&�y�ӥ��X�]Q1�����T�{#��7 ������.�C5��7�Q���������׏����W�hW[����s/z��-Gv��6,nx�U�>w�r'�M;��{@�7�����ц���K�a�ӢWM�S�op���뭃�?�ǽ�X�֨�&���S����؈	��A1���j/��Q�k��DD���Mp�H��z���Mz<���5���R{�Fޮ�/�Y��s��a�m��5u�Euu���! f�w#�\ɻ��x��	���p�-�j��{�I�ю�Ҍ�6��.�)Ib�v�1,+zaT���\��i8!����X��ݲvs����WQ�A��&#��m�&�IvbL�zt�k ����\{Mяgi��ge��Yu���H�:�����3LA�Դ�X��,��~N"��\&��֏f�{@ �W(�20���Gґv�84��yR+�Կ<1<PT�N����uq��2�6�l3�h�}V\2t�`kt����yHQ1!"N�z�p@w�8v��-|�B=b�yS��$`�`6�
�'Z�o�����������x��Ժ���S{�C~�ܭ���W����|'��-��@?�}Ŗ�7�������b�F[����~�	��怅B4 �''�ړZ��q	�L��e�T�`B��@%H�h��	$�,� e l�x<����)Ӏ`wh���8b�8�7=.28��(m@Z���k���D>�&-hc1��9F��ۤ>�����oO�m�VTf:�z�^u��֦|�Y�Ov�<�˹����(��w$��WgJ���q��Q��$��滍ng(�i����e�#��}:��]�{�$�(%fr2,\������	�N4�鎁יhF� ���@+Ҷ�Z��s�;6x�.p�>sK������/ˑO�^��5�DVʖ�<%��=^�-LݮS�ou=Ąy�E<�Wd��`l7��Bz�uҮ1��'U��Z�gRׂ�y����C�`<��j�)��5�@�>�w��r�`�V�u1���>��9����o�r�o�`����U�n�B4�}����̔�Չ����z�*׃��c�r����;�t1���ջgE;@lZh��"���&w���O��2|���3 dЬ\�#�p�6+h��5Y��E��)d{.fI�v�s&Ϟ�-U9edΜ������@̃�v�|�^�f���,I�i�t�s��=�l�J�������n.t������1��.�;`Gs��T8�8�GZ���R*��j���mOO�p���{�aC�1�׳tR�.<F[��ny�r�*4���#[�[=,�{��?.���a+|o&���V�뛶@m���o�}ȉ2��N��.�^pv���֯��9����){%Bf���<�x���\?��*W܂�%��]�P �NOZ�\V��S �A��#�Y9�]�<�|�{!��VӲ;�ר��CZ�y�@Aٹ��e^>E_��xѢO�����3�Y}NO�V���3j��?.��"&�8޺�J;�{_-��W�n�>�Ɵmԯ�˼�k��43�x��ꘅ�m�U����(|��}j��?*��pe<���y���L�X��8[7N��@kGa�����̶���}׮�����%)�������ӄ�a�����>S���/�ڥ�� e��.q�n�Ƶ����=��}u�8[Ɉ�G���Y���D��lYhR��I0�"O�]7i�5?�}����J�yC�@9Oɉ�s5��Wc3??���_<���#�����|T��lr8'�Y�n���)}��[m�?]`i����үxɻ��w��5?F�����Z���	㥫�j����oƛ]9����r��]��{���0n��,�uػ�k7�^~mYם�0�v;;��4�����މ��>^��p����N�HJ2����M�4l�'{�x���n�t��	�Ы1FG�
��2�x�aĺ�k���gq�+�����U=�ڟ�p3��2���ɋu��e@�f����uݩ������9��>w2����"p[��ޞ��[��>��ź_#�W����lm=�7������bh�!qJ����l���!z���L�'5T%٫�J�>	�&#Ys�Z������bPzȓH�{.]�^�p5߯;�;ݟSf7��F���܌���ɸ����+��s&%���?�{�;�C�oɗ�� vy;�m��]r[I�%���Ǻ���9��v+�Tf�\��j���� ����6���@����.
�қ}q�� y���ݬo�b�@n'��v�Q�l*��ި�饒�q�4We��X������J��'��>���@/����sn-�E%�xɿ��� D3[2 ���l�8(=o|7���*8D_�� . FF`�ʭ��j�Z�V���������5>��1S��x���̃�V��<M����͝���ͩ�u��j��6�gwC���U�ꣲ���o��h?:9kz��w3���#����J���3:�:�A���B��9�{��D^�� 11X*Ib������L����+��ݧ�������/�L4X�i�-aC�D�4ª�S9�]��xFA��)���+�v�dy+r!͡%� Ĳͥ["���S��w�-e���©�C��3�
t�cUke�L�s�������]����xz��m^���d��:�=pdd	A$FE&���ֶ��J�6��mCj���rN簾�����P�2W*E�J��{���P@�H(=���b�@���=�(�FRq���+�r�s37��'�^W��\��噙�������]:ft9\���?
�Hy=[ 5)*ح��.0��3)�̕x�-W-WOE�M�ڶ���ře��pqř��z��ݳ3333.Z��v9wR�S�˼m�xquJ�/�\gQ�&��˸�e��,�0r0U,C�pV�B�'N.�]Зk��-x���]��|��%����I�+U�W��7w�
���K�3:��6c(���2I�.p ��}5�>�����;�TM��Nм��{*|��y?kR�������>���\�?�Q�F'z����o���%]�� �<�����aj@9>֜�)M�7��K�I���X�����l�{���Oߥ��_�1����Y��DF��s:�?�m��R�\�׮WIo@��jNu���J��݂�����Mp}��#^B��yC�6׸мsn���Ʉ�21颥oD\~@z��f�o�;9�d��皫�@nV���>�L����+.��E�$��m�7Z��XP�uaⴴ)�b�ӦՈ�)S�wYO�}Ӫ�ȉD�s���pF��Jz�[@�6��z��o�Aw�y�
�1��s؁Ch^�S��� kJu;~c��[��5��w��j�ߎ�W�|�v�Z�ݒ� Z���=��h�E&�ot9�@[c4������rι��:Xz�T����0X!��e��>�)R��&�G����+7M����-9�E��>7�5[4��cQF�c6�D�9���G,s�6ў�$cѸ|Y9�[.��٧O�⽖�P��q���{վ��ݏ�3�y�'F1�@+�=p��{a-]U�.�^���FuIR֚`�eF�Z�U���%����4Gl���%j���E7Do��ь���y��z�~t��k��}?�f���j�))��"�oV�&�/wڠeޓ4��/��o� ?��b�׽��Y_�wu�|���F^��p]���9�P�c�w 9�!��@���c��F��ʯ��~K�M{��㿻���gV/|n4��''����hlg<n��0������/� /�Z���,b�7�_h~��S?���_ABYd@0�GJ�z1)
i���gn��lc�1����վ0�~���5h���Q�;��Jn�, F5��+	��ko7�WJ����g��+3�n��;��K?�J�si�!�O9..�g���Y�Aw�*{ec�7�q���N
s.����Uј���$[���,������(�ףy�3�o���FR�H��~�����w�[v3�c'�o],�GZ��VMd�Q��\\HC�m�4�fI/���n��Q�F�ʣ��I�ѿӬ~�u����Κ�w�^� �83cxݸ����#E�Ɣ���f��9�p�o������lI��;u�X@�D�F��/���u	����r�Z�|�e��]da��+	��Ȭ�lv��&�ʅ^V(��YW���d6�e�ڲ�0�키�22ڶ��Z�#:b�L-��*�-�[|���ީ4�:y~�CJ�M��^�W;w�����婰�\�(��7`31w>�7���u`�Ld��g�Z`iϣ��ˈ�A��)���p�����c�$��vv��[ �F2�<�����;5���5#m���ع��3m ��v��s<����_O��	6��U����ɵRP���q��gmY�[����9�/���n]����Q���I�U��?.�/$YpP��}zޕ�z�V��v���l�7o/#���13TG���-p&r��XK��,z�UH��x�VҬ�e�7�vM�Ul��(YY�s<-D7�4��V,�x��FԖ;7~�Ԁ������ 
z����!��j>�dN����Yi��u>/׵�4'3��7����7ɤ�es|�*���6����_��/�#��Pf��o�X�� 4��i���5��N����� b�_!�/�\rG9�����l״U�Os�y��W��Dw�ԇ�7�x�=O,P]2h�bM����M���<�0�?o�-q�!5h2y���/&���G�o�YQ�Q�Ma�jk�Cp$��{����ȕ�o�3A����G9Z(NR�J!�{@���k���G�����{$l-w)�{�j���#��$�Z-M� ,O�Vg�a����~��f��?���Kw�$�6�����b	��@]T/�\���u���x�,�&��x���>`��\&�r�ᒧk}lj���o����~�r��*�>���~�E���d�ۜ���.��_��N�M������̥�Z+���au������"����8Y[��B�m��<�}\���Y�=g�?�X}wB.(�=[T��4M_}�3\w��ÐOo���D:��5����L�1�b��������<���gS��m���U>��tz���b�ѡ����Y�k��_ؖ޸��!��tw\����H���x�m��'��<\�Vg?�ؼ�>T�3�/z+�N�AN
@' S�SO�&���p&� � ���T-%��S��A�k�M��r�S.�w{�QzΗ�-ކ��O-%c���"D:����c@X�f���5��u[ٮs����?z��4����2���w���x@R��ۚk�o�w:��j=j�b� ����r�j�{D��{�j���b�G�x�8�i�8��3�㓗h�]���zz�S64o�bR2�E��H��l�+�_0D[F�L�v8f�Ó�c�5oOg�L�i��G�u0K�_��n`��O��iB�(���>�<2ji]��c��>~"�=�����w6>7��R�o�<��|_�#�<M�I����Z-�qޕ;���?���g�MG_���k��K
�;;�~�w��PR�狖��&��柗؁��\b�H(�DI�a�{���ˁ�\�˪	C�1��j��������c%�, x�%�j����)�W�F�"����}����x�ji=��^�o��u(���RX�w���wGeכ��)�-��E��F�{� �t���/�����Pp�	��L��Y!��o�Ä�|e'��r������g��Lj�B<���e�����kgW���/�k�wƃc��S�ç��~���B���mAT�[�)��=:.���x�;����B�)΄�>��ͤ�pm5�ŏ���b9��m:�17@4�����	�RmCc]����>�P����!W�X����Q<���[A)���xv�ި�%1oy�~�>��Vz������%ɫY���4�U߄�Cg<��jfR���T��h`��1̼9�O�㻊t76��6W���&{���1�"y �o��|`����^�+�l��0�t%G��*�c�H��3��󦾉�ub.�$���@t��L��-�t�������,ߌcyI�a) �`׉��g�@��3�S�Λ���-f��%�!fB���iR���/���%k����� zsN��Mw�s�,ł(+쏖Q;����2"6EC���,2a��2K�? ��ր�_���Vu3����j<MKy����z|������2��`�jޑ��W�XA�x��N|Mo�����ɻc5I��;�?m�k)��w��y~�h�@"��3?O���2��ky�%����j1�t�܎�˰�Tlo�(_��b'_^_����$��{�.i*��Q�!q�ȱ�wt����Y ��K���Lvs�&�<���_��4���s���"�ns���G��{|vĿ57��$�z�QoL��X|ϫ��g�̊��u�M2��g \��_>���^Z���yln6�b+�>����]Տk�k�4�ǫ�a:>�]��@v��~x������F���]HL��חH�BK6G�z�/�M���FbjiI:FU��2M�Ҫdg��M6Ǣ�A��������E�6g���Kc[<��9��p�Ko��8�Df�ɝw�b�As�{$�Ձj��\���L�/ά�O�y�x���Qp�*���'�n��Ƹh��n�bd�"aL�P>�X�_���o�䁷�vky�}�u����R�6u�G�C���2vk�
;�0YW�ݮԜ�vR��;�?��?�JO����n�>���|m96���H�Rp՜��~��ns�Zx��:BYc�?8?���[Qg����?�|���_���g�W	���W������X7@>�OW�CP?�4���Y��`� ����U.Jf/k+|8���U�(���VA�P�(0ur����f�+opI�.���Y��� ﹪as���ϋ��#���Qb����f����[�y�Zv�:d�¶/��̷���&ϡM��f��b-R�~��VT��� ���¿)��gNu: 8B���U�ou�z�N�+�6�>��7��O��>�wJ�ʤèK���nϹ�R�B�,�Ɂ��(�P�����"�[n����fA �`���60V�;p݌��j��'g�{Ȭw���!z��c��"uk���]�b".>��WgGs�T^E��f-t؆�s��~�S��y/�4��^���>yD�vBFqyW囵�g�Z��Ϥ��O�ŝ,�ַ�j�C��'y��%t�Yim= ��ay�	1JM�n+C���Ό�&�҈�p[�5G�/$^_#�@_��j��TwN�oݕ�Z��S{~p;��O��YG����ed���+_���E��}T�N���n\���W�	Š8�lr/��oeY�O;sJ���
kA! ���k��Uev���3�W_6��e89�H��֝Kf!$�S�@��Ʉ�v�^"���ޑXm4MH0��f��73��ni�7��$u�8��������>���gζ��K��M���>�7zi�8&��}D'�
�cߗ��7�u=�s߃u��~�t.�Dq���^����Js�͛}Y�_� �<���X�uo?C����+�߰����7g���>)�/��7L�Q�lB��[ ���YӮ�/�٣�����t��%a1"�k�U�g���V���]R,k]�O�
���?��v^H8p켻dÆ�E�e�/HC]�_U_<J�ˡNf'�UU�ʼ�x_�mr��� ץ99����LV���3���=�ȐBzo��֎&�Hy�U��S3���)�E�-�D��e%d��B�x�BrHi4T���vOO��+�l����U�|W4���6s}�vG2lC#/�?!�4�T2lד|�U�9��Pu���}*	�3�!��R/ӛZ��M�w	ѹ$�v% �!\�`5��+��.�W�9���u*�['��[�/Q[����U�_˚�{y�������T�N��I�_y9�d{��(�n��$�����n�/Y~t��]ٞ��Q廼�ӣ�hE����Z����W���.z0������t�6�u����u.E7yC~F�� �J����=����<�" ϭ�m�[�%Ee��Y�TW�>z��xT��;�.����ۍ���Z�A�{<�-X�P�h7.��t��3�v�xD���Ρ�i�^wx�\
����2�,uG��i�[$�oB�޸4����]���s}�15�M�;�xQ޼��nZ��5!��b����QxD�N\f,������L��o/�����a��(M�ǒ&az�Y�*�'����q̝mKb���w�Ǧ�e<�Hz8�k��oczҾ�%�f[�V�,j\���JDyq�l���M�54�v�#��]׎��65�dW���5.-�L�[���p�iQ]��sd;ȥu� S�v�xŔ~罧��by�y��
͙�'��K*��#�ZW|V����[�8�����a����g�	�Ĭ<�)u�f|�0]e�χf��L��V���M#�Fy�n��q
ن[/{8���+�Z��r�>�����x����؀B���l��W��ϩ�uTށ�+��Y'h!����%���`	���!��Z�u��jљ,��2��	  ��0��!���}Il�����y�[6�u�Ѳhyڕ���ɽ��k��K���dDf�{l�
ܢ�!�òg���{�J�X���xM�p��n�ٷ֠A@��y��l��$%��H�����뺋��J��Y��1��Il�Ձ�.�&�)�9�	Q�`�͚公C���KԆ�sp��S,�Ό3T��L-��fG	GS&��VU�^!�����Q"�<����&�Vkh�-Su2)ý���(yS�i4�i�k��A�"�ͺ>��s�Bl�c�0� l�����ϯ�@��Yn\�E$Y� [�2���s,��_�I� �f�59�b�rᴯ���ɥ�&��He����[g��=͛4��.�pz:���-g.����+ee���1��êt�̬�+K������9Uȴ���u���8ի�wiZ�^�իV����ˢ��t�g�����������8�Ӻq�q�.���l���JlR%�!�ܺĚR6U 7�����º����\�k�_9�gU��%Q�"��~��������a����LV����Z<�"��O��A��kNU/�o����:CT��\���.�5�U�i��5�k�վO�bg��Ҩ^W�t����).�p�s��Wо�~&���~yzOV��ٱ��k���]~;�����i溮!։z ���=��4�}M�p3ݖ8�P\�_�￙�X�pސ�ә=ǆ��W���+w|ø�['4�
6�Z�r���2��&]iu^>��aN>I�(K�|�OR�O}���lojD���d���Wߨ#%?�IHxA!��	皲$�}7܉mr֖z��y��������W^:$}Ȣ��/y���7�Efu�ּ��q�ˎ��ܣƦ/��Lf�R�ȭ��"#s�k�՗�u�L0��n�������[_к	L� �⡶e˞xWǖ�7�Nn�����} �_\k��#��J�W訯�U��b���9hK���������U1{��)��k��}Y�Eվ���k~�G�;��6�l�k�W��srg��S4�:?52���-���G(�P��Ś��6�3��2�r��,��G=��B�DG��۫X[��Y�Y���C��B$]/j����vt�o��7ؐ��R�4���{h_�4^.�������P���>*���[na��Z���c�^t�<��n��J��!�wF�8n���l���9���ٔ8��ʽ�PM�l\N�k�9���jd� ���@I�ەٓ�]�x���H�������B�P73�������4�(t��U�fJ��e^2x�E̳��C�e���6La��j���"\'���;�E56��)J_�qN��ZFp���q}����omU�U��u�s9>f{y�8���ψՎ����JD��h���(9�_��q�4��qz�)���NN
x#��;�%�-Cs�_����������=���&3ޞ�Y��0���~Wj�,���z>�w���y�¿�-ƾg�N���{ve����]jz��Ύ���Կ�z���r{�S�-~�����=B_�w��Hc��_�k-}ʯ���ǟ��W7(]��������@�ۡ��ͷH�������۾�o�ϖ}{z6��l�[@��0�l5�l��+y��/.�C]���f8/8���*הB�u��9<�80$,`��@�j���j�ֻ��:�����:ǎ�t�]kdG��j_	�jw���E� ]j����jv��iBǐ���.�j����[ �W��le�a��>���4�l���(��)_+�yK�-# ������gT�O�i�N8�LBSqA�6SO�}�pr����O�� �ܺ=ƺ�_����b�zw���� ���F_���t��fȂFk���0<I�����c���K��V��TH��@/9�tj��1� �k�� V��9�<�#/kX3�֊2�s���)���'*(Ə����b�TI 5s��|f�׈��j�2����Kc�q��v̦�w!yڧ��'W��+ ׯ���^��}�������k��y�R$+�{`�g�p�v李_��W`w���R�@���M�P��+nl铭Hghmn��Ъ���b+����؋�i�"Y*�׫�\�z��)_�h���c�ظ�9��w�o�ݴ����u�oD�ey�-h��n�<�]�L0gh������S[[N����c�c���=n�k��ER��^P���f�1J"e���^�긱�P(�p	�5���u�X��h���ne�X6a�����!��ܓ(YrO��&}k�4�MP�_t��Gu^�O�������Ϣ������\�o�P'�ȩ�F��z]�x��\�7M_2�\sw)��;5��K�=ҿ�?7�h��A�m��p1�ª~4��V����S��Sf�BU=V��!2��|zϿ`��x޲/����'T=ߠmQ<�~�S�C����3�k��^�D�&�E��u=���O6{�x+y��@�V��k�MQ�5�����Sj�5c��!����W�lbO_'�L̻���j��G�@���h����jS�3�=��;q�B-�S�PI%PX��0�=�hKhU[w������,��L�&gK&�s)�[ry=?�v�����k���?��l�3��fPLfB�Y��ƃ��m- (i=��]��jcO�4?-^�k��j_?o�w{��&��ȇ�x�?���(۲v����_fz��cR�Z�|�h%z�^.���K���t#N��y�b�w�5v<������P�%��!�7��U���+;�ƫ ��cZ?8�~��_�G��{�b?h�n���S�Ӵ��;>s)|�����'�ܠ��������k����p2W��R昤�R-�����{}z�h�$�����3����}�
��~�3cF�d�_�eb�y��Tgj�Ӿ�=�_V]�}?�&���-�S3gM.��E��d�6��n��g�/.P|���w�Wچ6-X�C8?���,}�����9���>"{�	�P��C�Q�MSK�����ں����n���m�g�&�yMX�G�g�|9���?�śR��5���gVU涭Ζ�b2lL�}����4\ʓh�D����z��~l��v�;&�)���h�K�����PDf�t�Ά����XG����k�i�9��g���r!6�W���}��T[��ʲLj�g6gM���h`��%�l�~77�R=�#Tw����9��j�y��0G�Y��?���*X����_���AG�w�޶���P��:\V��k?!7��!;��;�ɇ���E"�vm&�٥dc�&���S ~!E����MsR�%�m��N�.������M#Ҟ�K��`�I\��c�*�Y��r�ʮ���J�?V ���������P�h������；�^�ف)0<'|g�p�>�@���}7)���y)��W�2%K[N]@.��o����Y5gP�9	��H���������i�[�l{=Qs��W�+��D�p���nW�����M j�w��9���(��k�!s�U�~��y�*��x�̼%5�u�WJ)�-��CW�u��O��OO� ��:�O7��� Tޟ���ގnw�1�FZZF�3�\Ff��V|�{Fg�4uC4G�^O$~���鬸���W�?����k1��JT˰Ĥ�:{Oś��^�<~^�g���jܡ�FRa[5�����岗�z+}sy�!(����v�gY}:�f���}�M�l1ɫ��C�)�i��vR��J X�\� �o.����ɺ��1���=I:�.�S.{�E�l�[4�k)��<'<+w���Y��$��:��CQ�+N��E��$���5��-J�kB��I��2f'^L���]JjU�ЂV͹��-�V���|�|���W<��/Lӝǯ�ѫS���d޹�Z�ˮ�A�\�Xy�Y�?G�ǫFʽ�j/ ��2�U�X�]��t��Ig|��R����\i�G��&ۗ�>��T�+5��~&hI��a����Z���6U����j�8֏�;�f�y��	�����m;�\g��0Q�0z��I�<IO/�݃l�'��4AƶތoZ�;`|a�A�n�|zR��ME�.�=�����q��k���2f9���ٕ��p�~����k�Y_��>bN�,�1�F"s�HWo8�cj�q�>��s!�P�ˀ��~�k���=��봙��u��l\��,z��[檵�f�i��2$�iw�g��*�qE��*R�̧Y���/��a` �~��bW������?������[��屸�K��۹y����c�/(S՗����b�Rf���U�g�0�n�d�
���܄�xC�v��Z>1�wdu���{�s��h�-�?4s�"hҦ�ja>��v·�-��C,���ޝ�r��G� YҖ��B=���j����W��+ԁ�3�zo( e(T����{�`9����C=����E�2�L�^yמ��Ί�ۇ �:9
���`8:�`��t�Le]ɚ@�s�����!v�ה�/7�X9>��Z���ݵ��l{��
��w��(�� L�T�AS������,Ξ_AG}�v^��-�v��D�\b�(���~U�FŘ
��5�\��x^֒�>���Ҧ�ھ̫�\��2�9��,fg�b�F�Ҹ�qX������}^�&Tߵ��p�W������Y�HjL�}ח�s����~�|�9���</MCG�/�Yec�p���&ek�&�&�yҘ��p�D��q�<F��r�TA:�Xn�G��[��M�6_;Ǧ߱k8���-�
wr��e����{h����K;�Wh�ROT���@����{���5����45Q�Ԍ��zX�/�;�L�3��L�I����恫�Kf|�=��ڝ�2�)��n?=��Z�0v�����C�y|����MJ�T��(G�vNq�GG
fz������]�}AV+oxp��YC5���͕����0v�z�.��>^mk���d��j$g]ڂ�x��kM ZLGЧ���(4�>r��q�n9��t#���O:PO ��d���8d07��{�N:�q�sLב �I�c�c������ە�0��l�xZ����{*yׯ���(�e�M���c�����2��f����^��<b/ܰH�5�
�|;}�?�:����{���a�:�daxYiA6u6f���$��f�,#;^��^R}<_���<�b�C/�u����g�e|�uR�4sx&�`�3-/�|!L���..NV���w˳��i��E]��n5%���e�La#�����Z�t�q�V0��5�H�����痨�Y��]���qZS����������=Gt-���B��m	��ϻ-B���#(iey��H��'*#u`�k�=�ٮ��;#�$�=�eZ܍#��Qw��@��]m�Y��1Z���nv��o}5{����Bks����Zh��hsg�,܉'�[�C�Zga�5�f<��_.��>����`}��m�Tk޹�>R��Si˃��L`d!\p�6�^�[8?�Cc�}=q�l�ӌe:�Z�y9nv��/�-���+��2�\��bHN��X�����s��7�R��������2���~����b���V���ӽ
��SW;ʍ'j�����W��z��?����݈����¬�m=^"�f����Y3B:�	n�ng���\t#	}��vB��)�{y�Zn�^�|��x�����z�S�y)J���`�(�eϵ�l^���c�߹����۾N��}{<���D���13�k�_�q��a|���y�w���|{���]��F�hK_�oV�)_�ǪGa�mM��cA͎���]<�N13�}��������BZ��ὭR2>�l���k���$7[��;�&QBj��/B/Iz����LGu7e��OB�U��Uf�g�N�9	{����k�4�lD��F���}���Е`�s�}��m�[��B뒻�S�d|��fg��wY�忘	�x��3n�	�:ߎ<C���x�g����8�$w�2u���ޔ�t
��$TZf�v�Ͱy��;n1}�Tb��ˇ��wZ���m�n��r{�@G��T��&U�f>!	������k�1Dl���6�����+t�b=��O=;N�Ԛ����n>9��׀FL��+�J�����n�[Z�f�o��KgC[���"�9X�˟���b�=0���1�}������ˡ^�ԉD�əRR&Z�eŕ�\��Ye3J��"P_X��|,Z�'F_Y�	�hk�:�;���K�N��6u#�Ѧ�-rP�5&!q������u��wj�1�ܭ.��ǈ|g A�rT�;�G-+q�tX�e\8cYMK`�%���^�Ik�0��tr�"�CԲL����Q��9;G��o6H88��w��kKH;�Gj��h�ST�10�����*J�5���YvccWjf�ifsp�0t�[��$ ���gf��Rf�~?ߐWF��r�x��sjs�Q\��!��$d䯓g��y$���)�'���Hq�;��TR���x��e��f�G*[Ans�Og��q��٥�f�eZd6���mj�t�C��J��x<j�l��V�M+m��m�����e�Zb՚�u<��x�xU9hr��Znٳ@�w����W��V����b��9��r�(�+�jhx�㋬̏����n�cV���۸�]jvi{��"Z��x�+�1N�t��!"n�Ρ+nh��iè���*B������k��П��m7{�zs�3���iÄ!�c������(Ѧ�<�j���y�f�h%��A;����柀.� ��Ta���h��?�3�{�Y����v�� (�./̙�j��%�EP"�6 �� 2~׌��x�<�Lh`j��k�B=7�h2"}��bV"2N����z�x���*(Uk�"����S�$g����<����'�������*t����Ј���ƙO-sZ��_Y���}���S�n�������6��r|������(rƭs>T�\\��t�C{<��^�!w��ϯ�w��i)�<��ǥ���3��wip����B�⺿ie�&��2��5t4/�}�"u���z�&H�jA���ֵ#��0M���j��oн�ϩ	�Ȼ"���e��#>�!k � ��s(H`h�Ǉrɝ:�N��s�Rd\� ��ITΊ��v����,��1^��p=�,��^�](-��rY�#�/5�w�e�w�.ȃyU����!�t���ٺq������SC�^fj�lȀЇ=�C�yj�_˃���1�d҄yM|o�G+T�g�xg��i}��FU@���Q�̷V�Hd~
i �c��mhkRa�ȷ�H��P��Q���b��2��B)!��Z���e<�P���C��戥�@�Wq����Onf�jmF�q�ѫ� ���	(B�*q�`�Ob1C�A-�u��{�������"?I_�~�����e�>�ܵJ�HH,�7�v���0��q�O���__�ԞjJ~�3.�i�!�d�n��"}-��6�����w�0f�g��ƛ������Lm��l�ȼ�E� ���!l�.��Aaڢ��`[� 1��������.��ES0wAb�lgE�sȑ�`2��fg�'�S�����!�Z�Ɵ���AY�*V�Њ�l�8�e�&]����>c�=��ffÂ������1�� 5�"�`(.�H�#���_�G�Rs�� h�P�����Z���".�*�A? ���.Q���afD�06��#�H��龆�	���]8�q���ڏ�Q�=��V[�}Yq����_>M�G?*�
q�,�%۞P2i�uE翷ٶf�W��߿�e�H��l�V�a�do�W���-�B��9N'�����������z����EV)��3�&��e`{�Y��~����'a��#��0�n����oGp����}��tJ��ёU�mJ!�f�-F��_�B�O����,{R�5����wVk��5+��3����e����,�̫�Fd��/�$�ƚm�CG�蹑Ty�*a����T�ٍg[q9z���ůFby�b2����A�{�b�v�?j,׌:������%���y��E�P��nՔg,Y�W�Y��,��̨ai���&lz�pKx:��x�o?V&�u�mx��������^�t��W�t�g��~�yě�p�o�����T�����]��^ b��[�2(����zMS~���_��i����X���ԋÉ˵!w��4�߄\���N����@�?{�얳Tp{�J���}������e����,�֧�<�o��,Ͳ����i�g),����iSn�q�V1�$;�����y=eVN�s��m�1�~>�gz[�c���鞥̿��q�Z��|�����M.T5J*�C%��0t{��7�n0���d�T/d�u����e֌Ŏ����Q�&��|��F�s�?��ˈߥ��8���[WՌ����������p�ҷ����~*��L�X���Ȓ+�͖_2�eB-
�[�ǽy�.�c9�ףw���n�7|���9�-��0�a�s���ގ�dDf��@ȹ�`+�Q'���c�T��t������0��*,�X2�Lĥۦ�aqJ)��֦l��z��.�J��a|.J�a7u�8�w��2�����T.ycp��*]�
�y�f�O)/�y�1�RI�uӅ����� C��3����&�Q�d�����s |i��;.���m_T�q�o��>m|S����[����1�L�nKP��u����~��9�O��nZPE�{�5��ܔ�t��0	���m�g"�]�����Tѥ��%Q��o��~��a%�d�ֶ����/������nv6�\�mMr�Cӽ6���ݖbk��dd��H����`w�$��5^4���n�͔��I�g�B�Z�c\,6�罹��$*C�hf9����d��ki|�A�>47>�>�r���#k�3�|�z]~h����7c#���.���ߪ��\R�o%V����x9�1]�1���z<�uZ{=p�����4m�kXT��� D �ō�eO4\}[D���W�=�D���S��5P��:������p�_WyB��H۞,����&6�*5�I��Oq�~���w5��S!�+o��I����u9ˊ�H�Ȝ��t��~��08x5^1���v�us$]���6�&sS��qE&l�[83|L�?}4��s���v�bؒ�t[�i��3L�X	K9��6��#��P�[�)�_����5� �̄�%2 |GT �ȩ�a�hK-�h�o��_���ͳͼ�	�T'��W�.w��$l���[�@���ąFf��ev��zSN��@�@X\꛻q��6%H*0�6wJã��qm�g�c�/o#]{#�9:.4��i4��eݔ{e�%DE�34e�O]�P*D�g0��@.'3�~���4����V�(���C�Ϟ�����u6c*�[���չ��+��6�{�.�M�����o_��e���;)?�~����Ƙ�	Xi<u����Z���_�c�DD^ dG�]L���x��9�8���RUԠ[7H�<g�����b�P�����AT5��y�ʪ�P��7�?s�����5�3$�2���F6��K�L���3����KSG$KњE�=��2y���Ϋ����eE\��D��۰�u��2���xR8\�'�u��8�Yqp�m��ɮ!����7�u�6�e�3ߨ��v2)�x���U�"�9;6v�,���R�Y} c� ���ύDg��9\��d����ɫjk��h�ce�j�kT���"/��/�{��E_8�
}�e���zAS��v�;��O��ߎ�[�f+�N��g��F4��S�4��d�ཛྷ���N��S�o�Y�f�)F�ڨc@�͉� �'I�|È�'��N&�^E��֋��]�xݓBH�b�g;�)�l7<zJ!���>�Rz��9�"J{'mF�|�1�sw�����w9",o?�Y����ڤ:�|�>���ն�j�t~MW3��ˤ����I�4��&vηN�3��>S�.m���E���WJ@9�tF��k%�o�4d/>��cRs��n���Oj���O�\W�[������uS�%�~�OsH5�^�](�g�O�}�7�B��;��vN����wK7��#���G9�W�%�,Ο��J��sLs@3ys��1�ӞS-�v�b����N�A�<���&Q��:���7�C�όz�C^om� {��z��t~�ʭ<?��3�=R�8𔿈�}�&-��� t�<�I�KGt�=)茺7�.�c-'�>�m{7�X 	8�V�,��q���%}y�a�����q��ګ�Y���#l��e�!CxnٰS�l������sD?`&�w�$����k`B����̆��f���3�� ����'�P�$Eho f��gL7�	��]����8y�d���E]?qZ��t��f�80���s�n���z�<��Ι{��<��{2͆�Uʞ����-S6�/��?�f:��~t���:/2��^ٯ&9<��F$��rt����H`˫�(v��[�3�Y�h�JA�:@�&��"�Qz�A��>��?����m�	����`s`|���\'@iY�)"f��l��+�v������7U�[so�0�>O[u/ˬ v�ݲ"����I:J 53��4�k�g��p��_m�J�|�'^1�f�T7��q�*λ)�s��N�\z����K���h��&�ߘ�GM�f�#0Rg���p��iR�؇��E�B�JS#�$ ]g��J��Q�.�B����G��8M�o?"�$�v� ���<>���^��4��k
�,ڹI���Ƶ����>4��� C�g���d��^�ȡ��+Ͳ��Z[��*3����m��P� ��,$]����;y_�c�S3�h��C#�o�� l��p��X���U��o=<%�iF/�þw��2�~���ƽ4
:�	��g��-�����Q�7��L�$�R${�Z}?5����Jsu6k����=�ӧ?n"c��vݩ�!��������I����l����6B�{��<�OC���+��~̯ReWY���[���R�E�Ƈ)z{�{{�$�شp��X�P�p�oh���/E�Q��O��(������J�e��J5ʳ��'~ڄ��WT�Td����l�7��JЕ����N7��v��>!���܍ޗa����� /Q�y:�*��W?e��<�j`
W0N���P��y��RF��t����{�>��T������[�-���YwS_:$�;�u��v�K��:�j]����c�g��Q.'�Ss64ׅuX�Y��!2�^t|.e5�o��ߙ�˝�p�G����_L%�7ݛ�3� +K%��hs�f=�z�Èk�ǣ���ѻ�� 7֚h(ߞ�'�v	��jv �k�Zy�<�����.��!r��ӑЅ�ܠ����>!�.u�r(u<"h�H�!n�����,��u�k1��)�疕��y����&��_�$K��.y�e�jQ����r�~ǣ��^����	�Wɟ,v�����ahoG�d[���G,�?%�[%���hڄWB���.kW4����oc���R�GdOr{�u<'m(��a[>H��¯�ۃK�t/S-pk=�1C�LO��Q�"���w����y�ືjr7�C \�	�UB:��Ceѵ[y"���,u�mg����]�[ZKa��5����dt���-Ͻ� xB��pą
�5����]s������4E�����[p��G`��Vg��awx�dY��~;8��4��u���,. ���κ��Y�͢J��g[mB�oe�o�=;/N�r2Q�oZ�(�ZLf~!Q�H�}�C��|ط1��W{�;�u� ɉ�k��Ne��4A�^s,[�����}����;�`s^��wŴ��q!�?r�����/9�POp��m&�p㖓��'���߼v�#%8z<�S�L욵��/���`��R]<��H$�����n�&�rk�,J������-><\)�QVE���C|��y�G
��W�a��v��O��cr3oJ3pM�ֵga�9�$���j�M��Z0�K����ݩ��-�����YUX��s�Ǜ�o����e$��i�q�f%f41�SYr��)������&�t�s��
�\�;n������O,Ѱ������l��?s�-�\�U[S�:j������Ϗ�z-i��b��� �p��K`m�}U>9˖Xb)���}L_o�݌��j����Y>��Mg:a�:�����׵_kk]d�		�}ºi&x�=[7�h`q����5n��u�������IA3��m^6�y����8k�4߻goJ/@nɗO�z�yl�������l1��n�=��@l�Z�4�u4����>��G˨S��R��]�r���O��R$|��_��Sl��S�-��L����,I��z�3G�m�ɵe���,FR@�" 9����c�ϣÆ��$L*D,9�=<�%�C)�A�kwqA�flRJQ��K�Th�F{	)/�j�b�H���WwI�����I�q���Ĉ
q6��a��!RZ�)������"�C�A!_�������1����~��|��(NP̒f�fg���\��W��4���Nf��m�S�~�C�;K�[2ժ�ԯ�s��"�*�l�Ŋ�V�+I(�@�K0��/IᆈT�U̵���詋s �� @����c��ӎN8�;��MS�,��U�N�m�e�ZeZ�F
ߤ\��>����n^�OU,�D[6��Z}��n���6�o����u�:��oA����6%�0͛�S֓��Zy�?U7:D����k+���>��d,�ȃ��5}��B/�!��d���U��Ԇȇw��e[�ʞ?��0�O��bߖ�
�k��]6F��S
޹u{�~D�>�,t�$+��(���m���ZԾ��ַf��`gؚϞO|{&Cr�y^�uC9���2-�G�.1�%W#�Ǌ�*f��:S3���n�ӝZ�;mVs���k��6>�����B�\k�j��a�>�f��Z+�pC�O���m!��\\;�-t���P������o�S�:.J�f2�ΫP����y]�<��x�ޯ��:3b��H�Z�l�����r�I�Dds=sW���������ԥ���<��ϔ}k�8(y�� Dm+��$�����g�M���1Ǎ� ��*���f6�r�uI�73���'��{ў�ۚ���d)�0vމ�y瓿'��N� ��t���E�G	5�O���dS���C�{[2U�炗���fQE#6p��LQp��W�W�c���eH�2y��^���ŲJ6Z�ao���lmL��L�3�tzy���,|ܩ$��:V�o��J�p|FM{o�(>���1s�Uz7/���^��c�Z ��N�j����o�	���w{�����`�/����}\��m���8�eہᴕ��K������fa2�P��X��;���*8��Z��3�ĈK6����4taR��H0��|��ܚĔ��t]jӎn���f�%�'�᎑fyzJ���q	�;>�{2�C�w���-yp�9ƺ��K�R���a=ސ��F�&�_פ@�E&5��^�Qt��(m(��|���؛�,+���̇��xՒ��IF�P[Oh�+z�;kƁ~6�d_U;Š�S�]��£�t4R���-��)[�^s�E�?~�5W�V�T'B&x����Y����3E�n��a��>u����|/HT*�HF��cqFo~��5ϏD��l�	�ĝ0��q�Zjz�<2Q�Ԫ&w^�h�*��J�;w��֕�kŤ�fFkݴT����^�����P�G
��Ցh̷r���ɾ���ef3���
N��asj�����i���[mƗ�T5���}�㾫7��$+���پ[z�O}�ߥ�d��o��C�I���̱�,�,���Ϩ�6L�+>E�ߘ�����We�Rױ*ֱq�c�(������R���y�cL� q*(�6���G��w.���������6=y�k1_�@�9�5���ӥs��i1
��<��j�}�3K8�ꕣ;�ϋ��o*�i�c���9�L̎k_�~y� f� �&w5��>�H�8����x^_���9�G�5=����?��ÖDi�� �m�o����+�5�ۧe&盎������=�e��d<#0[���ԗ"��,��K�VcA��z��~����w ~��ipKr�XP<�1�l��q�:��a9t���8al�:D�T �߅��;���L��'-4�ӏy�j�7HA8:��	k¼JMfU���Oxc����펥��/`}��g�^[4[*��wZX��z�د}�@#���ޭ�{4
yl��U��'a���I5����$�L_�_DC]�������nv�mK�y�@D?]~��.����w��H<g���w�}�jK��z'����Z�7��M�5����[�.�T�4�^���w�^���^�[S��<�� ���Ǫ,�*�|h�_�����������r�[��>qlg8���X��ߌ`��[+�s�>�?��� H���'����^x�-dF���#������A#Y�WK��[��zh�g؍��~��}���[a���^�BF|�����}�������^�C]����[Sθ����j2��y�C^Nם��䉐F��vcw��}+�٭_Q��]�@���Eϰ�t��jU'�jC��l���B?��(��~��wjթ�vO-�W�{���eb��<������péO�)�|�_��m���?R��M�6�>G�jt�IT���[���H$�7��8�3TV0dݪ�>�����yN>�&5�:Z�~������_|���:�d
�`@>��X�_o�J��2��ts����<��y�[�����;5"-u�O���*x�nQ�l�=��7؆�����|�>����\�����=��گ��OSK��1�	 � ���$t�@EH9��|��]|Ւ�3�2	���Hn���ͷ+У���:�Sq����H/��`NoH�_�x�W����f\_��!C[�?_����Z�V�P�^�5[�P4i���s@����	P��:͠�5��k��O
��k֡�N���A��=h%��zئ:!�b�È�\�S�Ъ?L�Ak�7گ��s��.��S��#��yu�nZF�[����;U;���_�o����E�����ޭ���ʹN `x��y��܋i��$�&)�E�l�[���W�
��W�^}[o�}\�d��'uq�@M�c�7�c
�&y��8��=h�	者�Z�͒��K������~����<sB����Ϻ�o[_���h��*�*I�(D���d;?�q;���#�_	O���N� ���t�����M6��S�������2.&�z/�j�Au���%�����ͯl�����2��_�<t�i���c\�h�	Ť0n�}ܨ�j>�@M]k>���5�y����O�u��x�i�/zu�l>4�����>�bF	���@-&��o��Z>�r�����u���������77{����9a��vipT�����/ǑC&5ř���$��N���M����:��"�����������8��ⓞuײh��u�
����m/�8�l[Y�h�G>�B9�]�_=�Lp���-N�2kGG`�us����x^SM��0�y����Ovޤ��`�	k+�������]�W�q7��8�궔�iT���o��d]�Л��xe_DwL��3�s���U���w��ns�䎔�{i����[k������޷���!����
���ٓ瞷[�׉|S�K�
�?�M��_�N>��g0�A�ѥY&�4�e6շ�k���K\G=N�W��83�8�	�5�C3:�6��q��������K��+G�h��L˼y����r�:H���ݧu��mJ%�`�[/O��� ����CJ�^8�����L-[a���A�o)����*�n{����$K�ߢ�����D�*��u������Up�}2��8���V�ͧu9�{'��6��<����a�\���ϟ�]}�5��?2����)���ׅ=l�x�ulcȀf]�h=9N�F� �aI�l�Z.�q�"���]�y���}��G������a�Ô���v�/D^�|,��|p���@�#A��0�*4�57�0x�i}m�O�#t��1�&���c��?sS��k}�RM�90�񳭳3_�=��~�џ77N6��l�zlV*L����z'c���|�e�:,[�!���hg?����A-g�!l��7+0�&����)�wȵ��wN�5��mO�6"����'_��}!��L�Ϯ	)��֖~/Q�W9;������h��zr�f��y�r3����/"�!`��<yؕ��<��C�P��ü��78���l�t��5�2&�{R�p�a���E����T����}en�����Z�J&[��N'����:�1�J'Q�N���n5��Խ$^���|��d4���Z�g+Mr��B���)��}t���A��������p���TÀo�����v�L���5��n 5k�yj�Aę��p����9�����y,���O����NBnuw�s�?R��d��h��	9�8��;c��m���k�5lu��N9<���I���s�$ ��o�g z�Wz/��?Ck�W��[h2W�s�&��:���+J�N��m������޶y7��#�m�U:��5x�i���q�opޏ�O���>o�^yGe�3�"�9�� �,�2�]C�Q|�q^r��ס�T-�S�]kHnò~�Ĩ���JZ���^�>9��{l��ۿ|��"Nw�hx�3ޮA�F�����_Z�i.o��s�?J�\�n�Zj9��s�Z?�F�&_�	9Jnx_��cSs�i"m.�]����a�þX\��᥺�Y�Ο���Y^n��9z��kK���bs��A<z��MI1��n�
欕!�u�nvL6�k���N�?K;F��~8��_�NS���D���I��CI?���lz���uEo����>�c�$�)�"�YY�6��L�\��vbs1� ����0����e~�TC� e��nU��E?b�5�h�c�˫�������|������.��8R_��w~�����C�˞g,ڊ�;�]Q�}y���ޠ��w]�Wc��