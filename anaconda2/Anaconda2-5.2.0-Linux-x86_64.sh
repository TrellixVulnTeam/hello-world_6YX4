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
1$����2��(�{hRSǾ�,.O�� n�8�  �� }��l� >���6m`�Q"���i�   
tҴ����x���;��@�|W�V�1�6�²ի5��Ĭ�fȴ��5�M��n��4ȕ�d��(��PP����'�k(4_z�&Vj�&a����f���Zˬ�C:�K�m��[SY����-m��� �
��l��������>}S�mj��
�����Ph�yn�����I���T2i5�c<��Z�CY��Z�e����l�EϷk�T
�J��	A�Z�ysp}���y��Mi-,�թl3h�e�ckn��+6���)��$4��Yޠ��ek+L���V�y�q{��J�IU6mSY4SY�Q�4�&[6��Ե��U�V�j�+�\��R��R�����[���{�xءfR�����X��-i[3*����c[2m����i��,CZiR�
�h�
*������۶jl�4�!S5����}��p�lőM����k��K@س*��Y�1�Ε@jF�����w*��ћ
� 4�jCJ�t4"�d	0�bSa��'���CM A���M0A%!DhJHh hh       @RB%=)���詴�SOҚS��G�i3Pbz��#M0i��&aLI䞃S&j
@�A89����a��_��������e�k�r��(߇�?�}f��rz������4�!���?�N��wO6��v�6����|���1�]c�y��6vo���m�\�'��s���h��:���.5�)���s-����5����7��1�lMCJ}�/�	��0�e��Cm���`m�������{vuM������)��A�s��Q��6����4��k����
��Qb�1WY�b�m��,�ūa��DE(E���mmkkc6���Vm���il���6�m�Z��H(+#1���UEH�+6�Z�4�M[Z��� ��6���!�Θ�
�E�3�:n��V���o�i��\qV3w����{����������|{يD@U�vEF=&�>�P�^��G�����O���^n���ZHt'>�p>����f�˞[z�����'ٕY��Uk�g��x��T#��0%��x��0�j?���ϕ�=3FO�1~g��zY?C�^?��J�/��zo�g�eTH<7�~�,dE~ɏW�C���/��}��������F����}�'xg^�����o��GO
�\�M��=uĐ�_�}���o��b���u�	�`C[����^��z�����'��%���l���I*g6L���������:W�o��{>�5�������־��qֵ�}?'���}�z}�8�ߓ������e�*,��,�Y,�EDe�2�Ɖ�Ee�%)))$.���J�
���˥��`��O���~O�U�>+���������<W\g���{}��_��>���Z�w_����u����sc���ɩ����{9<�
*%n�-�~��J�^8ȳa_������C���w��a�A�ї]���������̷og�Q[��nl�Ǽ�rb��i���zj����*��l���P��=j��<����~u{�������3�pw?5�VZ���t>������öi����Zsm�^i���V�j��=�,��0�P$� �@sW�^�l��ex�@�`;�x����������|V\��qy䶖�a�u[Vռ:��pz�2��
(!a�]��3.P@�T�� H�d�U��
>���d��h���)):D)��������P���.�{��*�����U�v��,���}C�?�_p����/�~5�����|i��x+���N�w�4� lz���L��jK%RRj��\�¯5l�B���|i|��-���:�j��v�}4��v<+��ؿxez��3�{�WߪR_�=���cx�0�t���y"���"�}����)��������y1\��b�������],%%$Yq}��U�/A����x��륖YY{��}�{����W������Ow��O�3;{�E~���hO(�ü����EzA�x�4��>C���O
����j�g�;~#�x]�u_�׹_�b�σ�_�����?���(*Wڮ�s-���7%�߈�c�|�b��ʇ��6�	puVf����J�i$䑰�b���b�Mw�d/%a���)���wOx��}B���+��+r���V�Sj�*~�&��_������{}>9~�}����􅯲�}?�-b���>��6?U-7O6�ke����fv���Q0�A�c>ڨl�d4�\���n?��ο\7�-��ﭟ�u�:x��'L+e�!�������3��OL�kA�_�ع�z7����ا��$jl�	q0��ݫ�������:��ǿ�q�$
@Z���??�����W_���j}@���^�r�^�9p�����;x|�:Q�=�Q���
tm�G!�h�6�C�K�g4=G��=)_���}d��z�Os�P�����j��03a_�����|��K��t���Z�&��B��s6�e8ӛ@��v=F����FF�40�+�:y&�v^�|eg�O�P' @�x�:����r̐��Q�&"ost(6LC���*���q�T�
6njj_&F�SEqx���!�����Ӕ%�J��o��j�BGh���rz�9��"��.[�x�Ѧ�^���O�Ǣ��?�m��_�w�"��� g�g����B����l��z��FS�ߛ�!�WD�O����Xx^���=��|����:�k;~Z��~����ė������3��o_���:�<�c}���J�U�o�\�ň|�������}�R�[|���{(��C��=]{6�e�r��������O��/�|�����?6�{;�GeWa�|Jnz�6���g�����D��2��LtӃ���/���7b"�_O��L�������?`{i��m
���;�!���Z��F$����S��͊��_��EΑ���~�ɇ�l�Ճر��P|����5ܰR���4����݃�g��c��j��Z'�*��JS��8,���A��P����Ӳ���l+C/J{�4(�LT���.��7��_'Q/��V��-P^|�VŏFA�꧎�=8_@�t�/m��`Z!h�f���2��#-�c�Y7wPX���n,�-:��?�����t#(B��E®h?p_��������5ٚ�ł��Qn��'�TPi����5��V?K��b�a�\M=��v�	1Qk�gF����O���1D�ʵ�q\��j��S��Q�賈"3_�c4TE������_�/|����0���5��1�'W�3@�a.�aL�^�4��UFO�ђyT�Z1���|��K�o����?.3>�_�7��
��±�XN��O�N�^/�@�0�� :2>l6p��t�63F ��U���0?������X �
h���;e�p��F	���i>�]v��[p�g㟍R�m.Z��|���
F�9
�1`��D]@�u�$d�
H��2L �QsD�,��Hr0��a�l�=���a���48
0�uS��t6O��w�)�zP�����0i�hl��.X��)��r���-������NNn�����]u�f�
#���cg&1��.9997n�7n���������ͦ��77GGG��i�i���R�pn�pi�Żf�f͖d���ozJ �D�d�#4�,���۶gnݼ�t���ުpX~\���,W2���R�cQd���L+1����C�&��������@��uq�AE#�\�d�-AHjQ��qR���R.�UH�7r�Z+Lu�
k�Qʥe�_��*m�Q�X.�.X�E��6��qn%s)T��%{�b&�mUj[D�1J[m�\��V4Ļ��v�d�9eZ4�q*��*"+���>$,E��Յe���O��iu��krpn��X��t�C��0�0����PRķ�F�j� �E�fQ��e0�ِ������z���G;��{��q���ǳJ�Mz�:�ԃ����C׺[l����ͳbm&��Q��p9uV�N���j(��/�ϙP-U���{�wE,[����\onZgD	�K�l2�sͪp�N�[��s���b6&ŵ[R� ��J�BT�f��EU������L@�J��H�L�bL��11�}����$=O���)R���������e׫EU˖�317�f���+����'\��Pt��>����b6-�����^%<euΩ������7.�U�C��9zu}�����n.צ�n�a�[h��Y�a�ۋ�*y��Y��ŕ�57n�����fwq�Cl��-�n8%��y��T]J����9{��wne|�c]��Kӎq����.�q-����oW��뗮�ݱ�����N�V�b��k�ق)�צ�V���eE}����������s\�uS�ͧ�ik*(�F����
��J=�U�Tc�B�ݵSr�֞϶�ֶ�3��.[��u�Y��TD�h����(�#���T��]o��Y�-�+����U��zt㫕x�_j]K�-�R�[击���N�oW߫6ݽf���ɗu6��*���KZ[�-;�9(�3AS�'������fJZ��Zާ�����ڗ���$��d������x��I��%u����J�鮙���.)�[[���-�D^�������%7�{�r�̉��
bm`����%�Z��fF�N\���뼃�rz��d��>�KsI���s;��[4�Uܾ�m�)�ֹ.D���]nﮚ�S9Ktͽ�����:n��u�ܙw#�N��9NM򨩭�9gEV�g���Tn8m�~�T��}�:��Mi����aXFB�9Ώ[��'I���?R+�¦�#4ĪK	�=fV�)4Iť7���e�Ȳb;]-���y�VWn:\>�_0+�0�k}qJE��雅m&"�t�f3�u�d�v����t�%�hu3�~�A5�R�,7t磛(��f�u�e1�1��7�ݹ��n'�GQ��[�Y��3nQ���+��:e������H��]뉖֭�|[F� �:�+k{4y�*�l�Wvu�T�.��{"�G2ӽ	I�S[7�Z�ʙвV����O��<7H.�ɍt�׽�s�u����)���\��Z/"-Q�4bq+��^!s���#��������:&?���5���w���]7�����}^���L֫���"�D����Y"��f�Yt�`�������	_���x�U��=������j�g0�5
j�~�+cW�F�j�����|}֓�Kc5�Q�7|��
�����S�����ST5g
������F�6o�Ǔ�?�B���9��C�ӆ�2y���Kmf`s��15k�uy�D�����{Q�����K�[."���y��x���I���s�!4�5�[�n���c�����)���5����-M�n~wV���k׆�8�q�������C��4�y�LT�[��bB�B1����k8F��B���;;��&?S��ά�7�E�(ǧ�4�*�z]�$y�Z��b��>~��|C'�w��Q�3l�K����Fʔ�L��H��1���Nc�:Od��B����B������kæ�������kF�hOxW�Y��h�W
"
,~Ʉ��-!���b
1����P� ,��1!�X�VE��ŀēZ�vZV9�d�J�mX�H�C˪�Vե��(�T@%�b"��t���?h�����d��%P�Z{�������4&+��Lb8Z��4{J�`*WӪqK.!�cI��� f4�抆�P�v�8�2`2��H�O�`��* `7F�PHPy
�y�!��1��]�
��J�k {��c]�lSS�,�e�_�H̙�C�r��0�30m�>��\`8�at>�R',���:�Ll�� ��$��':~H(����+'�;i��vXM^�I1�'$bX�^-�, T�҇x�P:��D:��Y�,]!<%%d}�v��X�*�f�紩��+B�<HB��Qn�CM�*RD��>Er���z8`������S\���JG>�M�9�?��>�,Ħ�����>3�`�2o�U��=d��n;�"�T(�,D� H�W:ÿ�����}ޖ�'S�5
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

����,U���*�E����b�*��D1Qې{~^䢮��W|T��� �V�V�چ��M%\�Sj��*ڊY�dZ*֊ږ�[Ej5bЪ�"�R���mQ�`�u�KO71A@� ���I�0�b���j/����M�?g���<>j:�'�ug���5U�,�
d�q���a�\&W!ɧ)�WZ�$�3����33o����L���2����(�RRR
A �%���S��6ff$�Y\Vg�r�ˊ�����.s,�efe\�8⸫\��+M6����8ۃ�89NS3,�9S*�S���NZ��+J䜇!��ߢ��Γ�r�r�̬�MMST�.-4�LZ��C����:UjuL��ML�)ơ\+���t�K%��r����\g�Z֜Wq�f���u���GWB�St*�S�H�*�s�$q�qs�j���T�t�.9�������㎇i��k���C�-kM893��2��8�3���8JⳊ��\��Y�V�r.�����	E\9U<��;��UYT�b�T�����KD�ZV+(�3ZQ�����������D-�H���Ty�(���ԗ��a��;�+�W�+����+��Z�����U�KeR����TnpR�ڨ;J*҉����Q���QWK�C�IE\�^|�u+�q]�(�U�����g��_���cr��W@��UU[��?��s�[�w3��l���Z1�e
���z�}�Ȁ������
!��7�������3��q���_����&�0& ~��V�}�|����s��v9~[��7�2��ϕ��
̺��a	��S	wt�R������zzd�@�tΕ ����a�"-C\�M۫�Y�SU�z8v�������C���!��*�.��^��M�Qm*a��Y��-W��xC;�DYU0�Д�L�n� ��iT*����"ԥ�٥5���Z48sPjfv��A��e���j��� 58�QQMiV�.�s�
8�w��[��r�.���ɢ��ܓ"ݝ���ݙ��-�E��R(E0�V�q,���"��nBB=<%,\Q�ص�4G:I�F���)k-�h�5��Ku�g	
C8�{V;XE��c�9w�L-���n��,J(�fhx8t`oj&�d DO-16t��h􁪪��b�m�Aܹɺ*�[�;��$:�[U�Ak&���+b�̝Z���ʝ�nE�K�ܘզ�Qʹ8�Z��cF1rwL�tf�L�A%%Վ�DX�`Ȇ��������\1MR�U*��K��=�����7��H-�L4�ө�Ӛ)˃����FTg��-���"֝�
��=Ê�������DMM{y��5��v�;�uS9��Vzh����zyDZz��%�F�qN����Z�,�9�YF�tj��J�T�,�fj��6�
������Y��2�9x_Ǖ;l�go�sj�Ű��˟�������XA��k�����kh���$2������|}�>1���������@?���E�����?-��I��uz\~��������Y��>T�9�N4r���8!� �oͩ�*UP��C�B��l���,*�px#��D0��@��-��� `�1�Sf�b�`����Rt0�K֮����Zڵ�6� ��N���;r8]$&B�P��	xO
�z�K��*��֒8�L`4hb\��~ԟq��(�ԝTb~�(;����J�A���C$���|x�{�~�H��ğ����A.���qS�(0������>��V�ڪ��ڪ�ȱNa��~��s�����W�Fp��h�~,=�>f~��;?Q�~�P��C�����Ȟ��EUS�C�N�Z�E>��	�l�)�z���I�̧R.Hz�=��m���D��?	��_�>����\�����dʬAE[h(���y�� ^�O�%��a�s,9c����jyT&g�`Y����]M�#��Ŀ�`Q�,X�Ą�9��*MM����~�U�i��7�|�X�M���M;�y���:��KUU_A𪪰9:����KԒI$�E
G1�d�������p��Ƿ�����!.���<C������?��!Ɋ�����ZֵX�&���B�ֵ���>G�~~�OJ���w�mj��#�����R���2ʯ���\�
E �d�
(�
A@""�cU$X(�P�E �,Ud�'Ǿs�������u���ί�ѳ~�48�Ǆ�����>�0=^����_W��?N8��M��&[���yШ��{�`us��n6 ��>��Ma�렦�xW�Q
��:���-U@�2 U
�P�
F�c�������}�5����+���x7B#��d��2��RS"D��
X��)(`[(�< )�8���ø��eb�� L��u�`�2��!C�K4ȩ��T�V����X���d��&��f�A2I�p�� �i<:
=i�A�N�V"�������z}fx��p	ѳ�����m0��
ڬj�Dh�KBҕm�Kdh����|����fe*ؖ�-`���kF�իmZ�γJ5���F��mm�t��F�m��lm���F�iiU-e��h����֗.!�KDKm��������Z�Z��[�qt��̾��"-�������m[[l�2��-0��`���EF(������A��IA���#��i��l��L���	��D�%���L �](2
�<\X�r�P����X��qź�96l���o�v�n..M۸����q9z=���ÏFg]+-V�ei������).�z�]��W��rHs.�p2K���RXA	��zC%ך��^��5�+�C�@�	�O:<��oA�맫�}x��Z�����!�e\����D$���Tp�2��J�Sz�Bl�'�ѽi�B��(@Ř�(u(�usu)n���$�*\ EHgf'�
 鑈EET�Q
�@@" �
�W�$(TLLL,Z�wcx�(P��htbc��3}=CC�݆fd3N�,!R�cF�$��&�!Ɍl0)a�&F3��QK���-)JJ�a��
[��,�� �m��m�X�#*��K (DL'A$����̃��rd�t��4(`������r�c��8�|9�n��D�#��d�s2�2�90�Ӊq���i-32��ДbF� �̞��L!3���5�33Τ$C��&��ez�j�ypv����ȰBâa԰2I�"�a��G��ZF&&��ɪ\CԷ��6d�ɏF�[n��,FC�0A�͛4 ��2ۡ���2I�F�H 0��1�I"�rP�3Ul� 	"�B�X^N��z n����n�I�9 �JF t@B��B0
얰UBÄґ��B��t>r��8oVvr�s��7���I�I�A�,�#9:&L�a2fa��W]��l�,���\�ܻ<S@�3&FN�(	�s�	I��S[���º���e�˒�lBd%%,�"�R
��3�vͶ�;�����́ �7
d�$ l�t�:dRi�l6�2;�u<�08�f�� �y�A��!�:���f	�M��	1s9��4ᣋNm8�Y�����pqB1�CF�cpJ�F�G��OWr�K�&�Y� vS`�\ ��X9�S(7��"��Es#@�C������j��am�i-���B���ݴ���@--�(#�t��S&����w!ͼˎe�4 a)ĆC���ĺ]��%���At����!Vs�gg9�j�XuaaXXv�a��i��@$J(�
E��Q4t�C�Ԏ��2!;��A�N2�476hh3��6z$�$u���ݺq��k!2@,�#�K��n7�+
ж@�́��4��"Ŏ�h\���a��YfD�s0���33õ�Wm6�k)ҝ�ҫ3h�9,BP��A�������\���Sf�$ �N@��":�$�Id��^�ӣ<�����v�P谰�n�
l�%U������NSg-Oa�e���
���jl�l�))��3Ll�n��0J���e��^.��3��'	z: Cfz��Q���-�nfg`�
��JK<rڡ!�4$���yl-�ɒ�F�S!qu5�������wqŵm"���VA���C��
�[nj�� {#�n}J�ۈ�s�Q����
�b+b�PFٲ�X�U����ƥ���Ĩ�m[*[*-�M���33dPD�ms�����(�GGq�4�o��*>��}\���u��mt�Lky��^a�E7'y<���[\�MB:	1���Νm��Jn7�j�LD>4ى�� @  � `���(�HEl��D#�X�4��ƒ��f��i5kkR�ll�%kb2��eW4d�7�.i>iu4��ӎ�M�mM���ʭ8�M4�l�*-����Dd�	Aa҅E
�T%6,�0�@%���J�m�3���ҵ+�F�@��PUU�	Td���Z9�3[J�4f���m6ʶM�����1[k*٘����٘����o�\E[l�U�Z��a��ʥ�d��-mM"�K
�YU�uW5�*�[Rl�Y�a\is@""��� `��A�����ޤ��e N���_�}��E���0F�p�����Z+��	(j��A�\�=,B�0;��E��&�&�%���n�Q��ҝզmP�-��۬�ڣЫ&V�r��n��v��.��Ze�G��V&�:c �A]��@��`�[>�6����ٷfF�����onz�^�,�$�@�@�$a	��:A�'�`Y,��	1�� k�B�"�Ì��@��$3-d�� 	$����G �0a�@�jճ�+�,��L;�fw2U���lVZk6��jٳj�kekO���fgN�ٞi���ViY,ڍ����y�j�3��\q�
*N�l��zJ�<S�֕����\fqǁ�7*k:)�t</�qq]�Z�K�uN�:��:�q�ruL�ҵV���W���D+dR!�`���2��)^]\��Κr�Z��������\�Xֵ��x�')��5�
��.Iq�gJ㎩�;�鋼R�Aj
	���\��\��9�-�+l�ί�:��n�.9����O���G뷛�?�����u�v�]���γ�����5ѽ��|��u�;_B��O���da�b�+��g���څ�~u�c��L�հC�_-�[Q3���Q����;�fZi�W�%A���[+_��%��;�~��~my�UKZѿ<|�h�V�L�ܻ~���{#;o%ٍ�Z���7u�G,��=c$�Jz!p��lN�i�+~s�z1�����d���+g���V��w���~ּ����m�k��dUɾ�-kKox�����H�i��F���U�ɚS}��~xc�c� �=��������sR�t֪�RGlc���x:~���f笌�}��iS����cT��>�S������ڙ0L(�x�gkf^�˶�tN�qM
�ԢS�TϚ����ug�U�;,u#4�*i�"eN���a���cΞ� ����t��3��U�<TC���NS�J�e1�Q�����4�3��b'�ݶ$_���W��[�o��:��C��.M*���2���:̚�,³"�'�C��`�0���p���?t�I���G����k���#����k�ק�S��E6D��V��T��B��^����0V�:	H����N�����M�e�B��o��Z\#x�]B��*���%�J7t��=�H:�4��p��L�K2u��=��W��P'5���?��\�z�l��j�.4��Lކ&c��M�l����1�x8�g;!��i9�N���i��q&�<���k�����%/K
��KD����
�af��$*%y!��g};�ǰ~��yX9��X������zm:��?u"d�B`1�SV��
�0[;zY<�T�1آ��K�)i�M�J�:NU��S�d�i��g^�|蒧f�\��G��@�c!�	Cَ(��v�g2,�pr����y�
_er�QyU=�w��=H�7�>�Nd���>7�A����x]a���W�j��jU���l�b14�u7[��������J2�nf ]���	�
�먳�k0'���檯{��o�Rdj���l�AJ&2~r5�q��8���"�.@<��MT��="8���P�����os�������}3��I��3vB>�D�o����Q{Y��K�F [a��2��7h�+��u�3м��
9>���W��K�)H���m���	l���ж�y����?���;]�{�!�
	��k2�E�f�	V����������}�{FA~���rߨ�#8[��7�<������������;χ��j��E��e� ���B�Gz�v�XX~�I�&rC�3X���#q�J��}��"���45U�	��w�K��`UC>���Ӹ6�ww�>Mk�)((�T�⎊�l돻/F����}.��Q�;y����+��Y}7�+�q�Y�┟-t������,O�������[:g���ݖȸ�?����� �?>~������Uo�4���>�E��i����mu H��L��"�]���9H�#��8 ��5f��L?^l�o�Ǐ�
����3�lݦ��ڞ*���) ���`8��xN,�σ\�^�����3u%�b��~�Ŭ-��>v?�y�u1���U���O8d�;n~��W��'w٪��<El��L��q^�[��	p�>�/g�q@���oM+���н)���sv�X����;)���%��C�4+����h!�a�$��pgS���G�#�F�"ܔ���a����\
d��~A�f
���;��T�}� �\�GC߻�����d����#x�F�kI��U��d�Kt��,s���\��'d�G[͌�TKT�[W04�X[��mS�G[o��,���0 �4@B ��R�%t+L���E3��#2�6��i�纎p�mɄ�D��[�C��ń�^���޾������-�����[�����\%�-�`cY�!6$+T�M)9�cf�T�U�(�r]��^�hN^����HȢ�G�ܮ��.Y�^w;��'b�z��ﺭK�;��0Y���^��D�".�;N�4�c��P	������z3Q�񺲐�g�=Lw�ovn�q�x���4�����F5Cٴ��f[Ü�0ҳ=�����
��Rs�g���e��E�ϲ�Ʀ{�}>�ժ��}�l��Y�1��N�p8zv�fj�|6
uj-ԭϛ,٫��	P����_*z�h��G|�K�ѓ?�ѵ�wz`6�0��;�/�f�Ro�jYs�[9��E�ڝ����{�Q���%�W?j�q�y�#J�{�UЇ��m�.-w}���J'(?}��.�N=Z�4]�B�4m�	G՘�ԏ-4��u[�"e�F��@y!3 Ԟ���jYW����/��(JR��6:���!�M	��yu��fϬ\�d�5���p��m���_�.���&VXްx��9��6TD�V�iۢ������ ��]ŋҪ�x+�g��[~͵8���cm#T� O�V�g���/D׍\uA��J��<���C�]�TZ2�}��2AC{�/G�i��@;RAS��By^=���:���~��T�>o��j�����1Z���S��#3�
40�FpQ������O�t�J\��gN�/Ϋ�1�oӞ�������
�S��SR�QY��6Z��
�)�FpY������j}W��3�+�u3�)� ���~o^eE��^i�)s���}*W��n���;o�K��fR+O��ɵ��O���//v��=�;o�T����u�yj�C/HK��zk����ݏ!�
	���Ui�2aO���FV��F�,�l7]]ML�MSUf���)�T�4�����H퀯GOU��v�x���9�A�E����sO��p*�Q3C�=��	�����
�!3e�PYc�� * �R�=EF��-�
� w�=�e�WG^��~FYʛ {���Nl�Y@� C�1@�$W��o>6[/�n������Ow����� �6C �P�
�hF녣�����y@��\���3�����.)�v�G! �2����uQfط���3p3R���ۀ� m��r�]��1�3�Q��n��榶�o�iC1Rʹh��r�o�G���B�� ��|
>������s����~O��y��$�����(��@��(}��j�y
iP�:�q�����8�R�����J@C�n�x�I'�������-K��!u�U-���G��
e��@�4�Ώm:�F�bs@^޶ay���I� �4EKFMR���8\P6����T��㳘 �-�������7��@׃�8ڼ�����ڒmT�Mo�v�wO�F&r>Pǣ�Zqo���d���็��Կ�#��$������_V� ���d�ӾHg�4ZR��S��i^��f�=��Pz��&�/є�8V�b��}���>�MT���]��D��7OhlhTa������*ڥ�}ƨ�G��z �uW��ƺ��#�ˏ:�݊̃�{f��|����}u�g�)�{��R����'��isa>��϶V����z̔���'�M,�-/)�(XJ�6u���$f�9��>a$$)癪�]���*�n�B|�9�� `��جJ=u�?o�8P�}�iA�w��/l3�����S���?Q"X1P���),~J;�G0�D��&R��w�o ���#N�G���E���h)fK5���<k5�S[�.�yj��p(r�ɦ3�x���Z
���]����ɓ(����/u{x	D:HA�)�2S1í\�z���VMq�D���Gqz����w�����P�Ĺ}���i���2���J�$��!i��5��/���-�N��or��Ry��?V���.)�(�������c#~�.�����RHދ��R����ABʑ&�~�K�*;a���r�~/���x�۲5��V��s�ާ~
����d����W�Tڿ����OA���=�d�,? ��c��������\�mg����[i4��h�'��|��l���ܼ������^��}�_��|:iz�*�I�;:"�!+�o(9����[;�/Z�����qM��d��������~������G������D<N���A�@��%����������ל)i[���ֹ
��*��7̏2��+':��xj�K	wv����n��;���J�2\��;o}�u�jr��֛��˖9�?�(*⣣+��#K�vɆD��6�J�I�����S���qOÙ� e��U�9%�W�@X 戉���G�-���lI�z��j����C�|1��5sy��yl�Њ�w� @����QQ
��L�F�
	�qX��8A� s�&�)E��$���mS'�#�*�_��jj]
0����jy�n?�4F�Ըs���?kT��.����Ըǻ����Ծ6�>�d�@�Kԗ��G��R���-1эX����� ��+��䵜5�����@i���p���L���쀽�'=�.gQ�h�s�'0�w.���#�̈>�^�o�,Xh
Y��7��Ws�r.�?rB-�h�����1���
y~��F{���u�C��{#^ü�~���'%�tu9\���͙���e9䯈W_k���4���+�c)=!-5��W�
C^߾T�;��wehV�v]�k�x��o������;�=3V�g�6���TS7�Ϋ�Qc.�Ũ�o�N������
C�'g�la��Ǫ~y����5��I���ؚ����	�bo��A�3���l��Hi�T��\��|�u4y�WaJ��oN�FR-A
��$��Ĺ�d�ЎOT	mvw���2�g��r�ٮN+�"ٹ�_����.~��l�q���v<�]�wc%�!� ���� �g�)p�)F��}�z!`����z]˿�3��Ct�;-��
�u��o�H��A� _���jy�g[�=T�p�}3�d�W�	�.i�,X���9l3~���J�p�ժ������g�`Ft_q���� ��Wm~��WUT�S�p�3��� Y1����@��8V5��O�U4 l����F��'F��__9tǷ����:�:����p��������we��
����KuԻ��^���C�B��Zq���@Ϋ�� �P��b��W����	����({�x�#�wz���Eoc���7��Os�g,��_�<Q�1.\{{׾��Z��
�'�V�t{C���i����=���Ս�<��)��as���[r��'���u��k��괠v�c/�y��e4��
���u���J�}w�����$�a���k/��y���
FeC+y.���;%�i	�<�h�{N�K�7���7�����a
p�kw�sI
��8�
��ZW�������2\�� pz?�̀�+�0B�V���#�*��V��YősC���ŤթW2WT����l\s8�휲\i�T���*�)��a$�"~Fc��~�k��e�R��l������δ�7�R7�o5/���-���3�߄6�ڽ
�K@[R8�,������4���+
D`��b��6������i\��0 ��A�;�H	�J!1*�j*�$�'��M�h��*��))Ul��P��,���̺��+f��+V�TԬ��)�Xt0�mF�l��Ҹ0�T�j�j�R�IN��/T`):�H���:�NL̬\ru.�U^6ںu\z��5��⪼]��#�݆�N�e�զY���̗H��4�J����r�u\gJ�j�X�V��t��J�v������-yK���`X@9m��a�d%���+Z�ӷl�*�ӣ��ɺ�絲�vR��t<��u%˃]o�<\��O3<Yj��T`]P�]G�d{xq�C`6���?�6<濽�j:f�Ũ�d<��W @�T����.5�d������սtq��,u斑�濶i�`
�{��OYB�<�	�����э(�OQ���S$\H�g4�D�Ng>ո5�KtS�iOً�X��^1g�F�1Zk:���"�6�뫲�_5Ϸ� s8�sG)� :e�j:�z��c/���]yoL�/R�[.|�L�w�=�.E,Ʋ��YI�$4 ��;Q�˺�F��,��X@�u@��DY�s_s�I<�;nXxc�Sל:w�!kA���`Z�;�{�I�|y�H �6Cbo)K��\Euꈸ�!�>wQ��q�&�
�2n�ӥ́2`����g#qM�ck��i�[����g�2���3���7N}Tyz
�NXuϧ�ċ�`l�y��w��<~�ނ��=��M���q���F>h������9�V49]و�'��b��4�y��8�:���M������t{CQ��m�Vr���ЉS9x9���?[O�9{?D�s�-����Z�Ɍ�9��H�o�#J��:78���+ow�I����	Xz��z�q����+����Οj*xG��ƺ�x��zN_5[����Fq��e�$��ϒϲ�+�E����������LR����Ľ�s�Qh��o^�7p��J���1׊�w��vH����a��s�}��`1O}��|S1��E{�+9ү<���`�ck����#lN.��{�G̴n��݉]�y]D&䄯� pfc(w�U:�F����Z8ܮI����t��{A�J�Į����s����"ѭ�)����N\�k9���s�s���0}��O�5�۶+y5��~Eo�Ҿ�s�¦��]�H�DOu�;�z	�^ڎ��n2�y���z\e,y9�� #m5U�Hl�n҈(��J
����י{��/�o�<�^����К���V���h��2�hK�}�\�KV�>�*�a��MM��A�+N��cB2��I�ƾ)�z�m�����zP�k4^����sS�38��ɣ�@"MP�r蘲\]B�O�l�N
S���}�^�� !N��TL(ɍ�$(`��.�oD*��/��i�Ōь�G��{�3_�}�}I���y
��+��W��:��؇Kl��D3�������U;Dz-��
)�ڙ���Zө�Ϳg��>}N�2ΔO�|.�����Y���L!a/m}��~L�����lk(��n�.ы��3 0���%�i5jP�8ϊ�ɵr��d`���z�>����n��+���(3�I�C9TFȗ�B��|�Rwͼ�O�4 �V#��{��<���-�aɋ�G���������ڷ�����O��CU�u����a���r_��@~&���#����������y���:?�b����vx�J����x�@x��H������&�mI�f���j[y����S�??���+q�}��,�X�x��k� �N��'\�p�){�j�>��蚛i�_���}g)����{cϐ��e5�I)�^����������ǵb�z��e[�;�)�f�|��u�����B�Ș�>lPC�2��kc�vLP;�k��f�S���P�Q+}�TZ�EN"ǋ<������'[|��qs
�d����	��L�g�f=.w�E���j�����U~�= ���&S����]*��e���|�i�q<�D�ƛPH�iV��4���k:$-7r�L��F@Mu����e3=�T��p�]�Vc�����F�wZ&����}���CQ�����W~ 7�k�q��F�؋�w��܀��)�ę�1� `�7D|�t�M\E�0%!Z<��
t��z|�7]���$����̈́�P��T���g�6���������,P��������a���Z�K|� _j
�ZUd��g?�����~oLr)ve�g��o��T_:c���?��Rw2ڑ�EKޅ@P�\�c��������rQ�U�?�{;Փ�y8�8ח8<��TY��z���3.�f�	��W'I�6x�G���|�����_�\.�q������e�21���DC�>�8�y+�*�|�;��Ac��_���M�
O���4��٩��~�=2t��u���*j��*�5[����4����&�y�ӥ��X�]Q1�����T�{#��7 ������.�C5��7�Q���������׏����W�hW[����s/z��-Gv��6,nx�U�>w�r'�M;��{@�7�����ц���K�
�'Z�o�����������x��Ժ���S{�C~�ܭ���W����|'��-��@?�}Ŗ�7�������b�F[����~�	��怅B4 �''�ړZ��q	�L��e�T�`B��@%H�h��	$�,� e l�x<����)Ӏ`wh���8b�8�7=.28��(m@Z���k���D>�&-hc1��9F��ۤ>�����oO�m�VTf:�z�^u��֦|�Y�Ov�<�˹����(��w$��WgJ���q��Q��$��滍ng(�i����e�#��}:��]�{�$�(%fr2,\
��2�x�aĺ�k���gq�+�����U=�ڟ�p3��2���ɋu
�қ}q�� y���ݬo�b�@n'��v�Q�l*��ި�饒�q�4We��X������J��'��>���@/����sn-�E%�xɿ��� D3[2 ���l�8(=o|7���*8D_�� . FF`�ʭ��j�Z�V���������5>��1S��x���̃�V��<M����͝���ͩ�u��j��6�gwC���U�ꣲ���
t�cUke�L�s�������]����xz��m^���d��:�=pdd	A$FE&���ֶ��J�6��mCj���rN簾�����P�2W*E�J��{���P@�H(=���b�@���=�(�FRq���+�r�s37��'�^W��\��噙�������]:ft9\���?
�Hy=[ 5)*ح��.0��3)�̕x�-W-WOE�M�ڶ���ře��pqř��z��ݳ3333.Z��v9wR��S�˼m�xquJ�/�\gQ�&��˸�e��,�0r0U,C�pV�B�'N.�]Зk��-x���]��|��%����I�+U�W��7w�
���K�3:��6c(���2I�.p ��}5�>�����;�TM��Nм��{*|��y?kR�������>���\�?�Q�F'z����o���%]�� �<�����aj@9>֜�)M�7��K�I���X�����l�{���Oߥ��_�1����Y��DF��s:�?�
�1��s؁Ch^�S��� kJu;~c��[��5��w��j�ߎ�W�|�v�Z�ݒ� Z���=��h�E&�ot9�@[c4������rι��:Xz�T����0X!��e��>�)R��&�G����+7M����-9�E��>7�5[4��cQF�c6�D�9���G,s�6ў�$cѸ|Y9�[.��٧O�⽖�P��q���{վ��ݏ�3�y�'F1�@+�=p��{a-]U�.�^���FuIR֚`�eF�Z�U���%����4Gl���%j���E7Do��ь���y��z�~t��k��}?�f���j�))��"�oV�&�/wڠeޓ4��/��o� ?��b�׽��Y_�wu�|���F^��p]���9�P�c�w 9�!��@���c��F��ʯ��~K�M{��㿻���gV/|n4��''����hlg<
i���gn��lc�1����վ0�~���5h���Q�;��Jn�, F5��+	��ko7�WJ����g��+3�n��;��K?�J�si�!�O9..�g���Y�Aw�*{ec�7�q���N
s.����Uј���$[���,������(�ףy�3�o���FR�H��~�����w�[v3�c'�o],�GZ��VMd�Q��\\HC�m�4�fI/���n
z����!��j>�dN����Yi��u>/׵�4'3��7����7ɤ�es|�*���6����_��/�#��Pf��o�X�� 4��i���5��N����� b�_!�/�\rG9�����l״U�Os�y��W��Dw�ԇ�7�x�=O,P]2h�bM����M���<�0�?o�-q�!5h2y���/&���G�o�YQ�Q�Ma�jk�Cp$��{����ȕ�o�3A����G9Z(NR�J!�{@���k���G�����{$l-w)�{�j���#��$�Z-M� ,O�Vg�a����~��f��?���Kw�$�6�����b	��@]T/�\���u���x�,�&��x���>`��\&�r�ᒧk}lj���o����~�r��*�>���~�E���d�ۜ���.��_���N�M������̥�Z+���au������"����8Y[��B�m��<�}\���Y�=g�?�X}wB.(�=[T��4M_}�3\w��ÐOo���D:��5����L�1�b��������<���gS��m���U>��tz�����b�ѡ����Y�k��_ؖ޸��!��tw\����H���x�m��'��<\�Vg?�ؼ�>T�3�/z+�N�AN
@' S�SO�&���p&� � ���T-%��S��A�k�M��r�S.�w{�QzΗ�-ކ��O-%c���"D:����c@X�f���5��u[ٮs����?z��4����2���w���x@R��ۚk�o�w:��j=j�b� ����r�j�{D��{�j���b�G�x�8�i�8��3�㓗h�]���zz�S64o�bR2�E��H��l�+�_0D[F�L�v8f�Ó�c�5oOg�L�i��G�u0K�_��n`��O��iB�(���>�<2ji]��c��>~"�=�����w6>7��R�o�<��|_�#�<M�I����Z-�qޕ;���?���g�MG_���k��K
�;;�~�w��PR�狖��&��柗؁��\b�H(�DI�a�{���ˁ�\�˪	C�1��j��������c%�, x�%�j����)�W�F�"����}����x�ji=��^�o��u(���RX�w���wGeכ��)�-��E��F�{� �t���/�����Pp�	��L��Y!��o�Ä�|e'��r������g
;�0YW�ݮԜ�vR��;�?��?�JO����n�>���|m96���H�Rp՜��~��ns�Zx��:BYc�?8?���[Qg����?�|���_���g�W	���W������X7@>�OW�CP?�4���Y��`� ����U.Jf/k+|8���U�(���VA�P�(0ur����f�+opI�.���Y��� ﹪as���ϋ��#���Qb����f����[�y�Zv�:d�¶/��̷���&ϡM��f��b-R�~��VT��� ���¿)��gNu: 8B���U�ou�z�N�+�6�>��7��O��>�wJ�ʤèK���nϹ�R�B�,�Ɂ��(�P�����"�[n����fA �`���60V�;p݌��j��'g�{Ȭw���!z��c��"u
kA! ���k��Uev���3�W_6��e89�H��֝Kf!$�S�@��Ʉ�v�^"���ޑXm4MH0��f��73��ni�7��$u�8��������>���gζ��K��M���>�7zi�8&��}D'�
�cߗ��7�u=�s߃u��~�t.�Dq���^����Js�͛}Y�_� �<���X�uo?C����+�߰����7g���>)�/��7L�Q�lB��[ ���YӮ�/�٣�����t��%a1"�k�U�g���V���]R,k]�O�
���?��v^H8p켻dÆ�E�e�/HC]�_U_<J�ˡNf'
����2�,uG��i�[$�oB�޸4����]���s}�15�M�;�xQ޼��nZ�
͙�'��K*��#�ZW|V����[
ن[/{8���+�Z��r�>�����x����؀B���l��W��ϩ�uTށ�+��Y'h!����%���`	���!��Z�u��jљ,��2��	  ��0��!���}Il�����y�[6�u�Ѳhyڕ���ɽ��k��K���dDf�{l�
ܢ�!�òg���{�J�X���xM�p��n�ٷ
6�Z�r���
x#��;�%�-Cs�_����������=���&3ޞ�Y��0���~Wj�,���z>�w���y�¿�-ƾg�N���{ve����]jz��Ύ���Կ�z���r{�S�-~�����=B_�w��Hc��_�k-}ʯ���ǟ��W7(]�������
��~�3cF�d�_�eb�y��Tgj�Ӿ�=�_V]�}?�&���-�S3gM.��E��d�6��n��g�/.P|���w�Wچ6-X�C8?���,}�����9���>"{�	�P��C�Q�MSK�����ں����n���m�g�&�yMX�G�g�
���܄�xC�v��Z>1�wdu���{�s��h�-�?4s�"hҦ�ja>��v·�-��C,���ޝ�r��G� YҖ��B=���j����W��+ԁ�3�zo( e(T����{�`9����C=����E�2�L�^yמ��Ί�ۇ �:9
���`8:�`��t�Le]ɚ@�s�����!v�ה�/7�X9>��Z���ݵ��l{��
��w���(�� L�T�AS������,Ξ_AG}�v^��-�v��D�\b�(���~U�FŘ
��5�\��x^֒�>���Ҧ�ھ̫�\��2�9��,fg�b�F�Ҹ�qX������}^�&Tߵ��p�W������Y�HjL�}ח�s����~�|�9���</MCG�/�Yec�p���&ek�&�&�yҘ��p�D��q�<F��r�TA:�Xn�G��[��M�6_;Ǧ߱k8���-�
wr��e����{h����K;�Wh�ROT���@����{���5����45Q�Ԍ��zX�/�;�L�3��L�I����恫�Kf|�=��ڝ�2�)��n?=��Z�0v�����C�y|����MJ�T��(G�vNq�GG
fz������]�}AV+oxp��YC5���͕����0v�z�.��>^mk���d��j$g]ڂ�x��kM ZLGЧ���(4�>r��q�n9��t#���O:PO ��d���8d07��{�N:�q�sLב �I�c�c������ە�0��l�xZ����{*yׯ���(�e�M���c�����2��f����^��<b/ܰH�5�
�|;}�?�:����{���a�:�daxYiA6u6f���$��f�,#;^��^R}<_���<�b�C/�u����g�e|�uR�4sx&�`�3-/�|!L���..NV���w˳��i��E]��n5%���e�La#�����Z�t�q�V0��5�H�����痨�Y��]���qZS����������=Gt-���B��m	��ϻ-B���#(iey��H��'*#u`�k�=�ٮ��;#�$�=�eZ܍#��Qw��@��]m�Y��1Z���nv��o}5{����Bks����Zh��hsg�,܉'�[�C�Zga�5�f<��_.��>����`}��m�Tk޹�>R��Si˃��L`d!\p�6�^�[8?�Cc�}=q�l�ӌe:�Z�y9nv��/�-���+��2�\��bHN��X�����s��7�R��������2���~����b���V���ӽ
��SW;ʍ'j�����W��z��?����݈����¬�m=^"�f����Y3B:�	n�ng���\t#	}��vB��)�{y�Zn�^�|��x�����z�S�y)J���`�(�eϵ�l^���c�߹����۾N��}{<���D���13�k�_�q��a|���y�w���|{���]��F�hK_�oV�)_�ǪGa�mM��cA͎���]<�N13�}��������BZ��ὭR2>�l���k���$7[��;�&QBj��/B/Iz����LGu7e��OB�U��Uf�g���N�9	{����k�4�lD��F���}���Е`�s�}��m�[��B뒻�S�d|��fg��wY�忘	�x��3n�	�:ߎ<C���x�g����8�$w�2u���ޔ�t
��$TZf�v�Ͱy��;n1}�Tb��ˇ��wZ���m�n��r{�@G��T��&U�f>!	������k�1Dl���6�����+t�b=��O=;N�Ԛ����n>9��׀FL��+�J�����n�[Z�f�o��KgC[���"�9X�˟���b�=0���1�}������ˡ^�ԉD�əRR&Z�eŕ�\��Ye3J��"P_X��|,Z�'F_Y�	�hk�:�;���K�N��6u#�Ѧ�-rP�5&!q������u��wj�1�ܭ.��ǈ|g A�rT�;�G-+q�tX�e\8cYMK`�%���^�Ik�0��tr�"�CԲL����Q��9;G��o6H88��w��kKH;�Gj��h�ST�10�����*J�5���YvccWjf�ifsp�0t�[��$ ���gf��Rf�~?ߐWF��r�x��sjs�Q\��!��$d䯓g��y$���)�'���Hq�;��TR���x��e��f�G*[Ans�Og��q��٥�f�eZd6���mj�t�C��J��x<j�l��V�M+m��m�����e�Zb՚�u<��x�xU9hr��Znٳ@�w����W��V����b��9��r�(�
�jhx�㋬̏����n�cV���۸�]jvi{��"Z��x�+�1N�t��!"n�Ρ+nh��iè���*
i �c��mhkRa�ȷ�H��P��Q���b��2��B)!��Z���e<�P���C��戥�@�Wq����Onf�jmF�q�ѫ� ���	(B�*q�`�Ob1C�A-�u��{�������"?I_�~�����e�>�ܵJ�HH,�7�v���0��q�O���_
q�,�%۞P2i�uE翷ٶf�W��߿�e�H��l�V�a�do�W���-�B��9N'�����������z����EV)��3�&��e`{�Y��~����'a��#��0�n����oGp����}��tJ��ёU�mJ
�[�ǽy�.�c9�ףw���n�7|���9�-��0�a�s���ގ�dDf��@ȹ�`+�Q'���c�T��t������0��*,�X2�Lĥۦ�aqJ)��֦l��z��.�J��a|.J�a7u�8�w��2�����T.ycp��*]�
�y�f�O)/�y�1�RI�uӅ����� C��3����&�Q
}�e���zAS��v�;��O��ߎ�[�f+�N��g��F4��S�4��d�ཛྷ���N��S�o�Y�f�)F�ڨc@�͉� �'I�|È�'��N&�^E��֋��]�xݓBH�b�g;�)�l7<zJ!���>�Rz��9�"J{'mF�|�1�sw�����w9",o?�Y����ڤ:�|�>���ն�j�t~MW3��ˤ����I�4��&vηN�3��>S�.m���E���WJ@9�tF��k%�o�4d/>��cRs��n���Oj���O�\W�[������uS�%�~�OsH5�^�](�g�O�}�7�B��;��vN����wK7��#���G9�W�%�,Ο��J��sLs@3ys��1�ӞS-�v�b����N�A�<���&Q��:���7�C�όz�C^om� {��z��t~�ʭ<?��3�=R�8𔿈�}�
�,ڹI���Ƶ����>4��� C�g���d��^�ȡ��+Ͳ��Z[��*3����m��P� ��,$]����;y_�c�S3�h��C#�o�� l��p��X���U��o=<%�iF/�þw��2�~���ƽ4
:�	��g��-�����Q�7��L�$�R${�Z}?5����Jsu6k����=�ӧ?n"c��vݩ�!��������I����l����6B�{��<�OC��
W0N���P��y��RF��t����{�>��T������[�-���YwS_:$�;�u��v�K��:�j]����c�g��Q.'�Ss64ׅuX�Y��!2�^t|.e5�o��ߙ�˝�p�G����_L%�7ݛ�3� +K%��hs�f=�z�Èk�ǣ���ѻ�� 7֚h(ߞ�'�v	��jv �k�Zy�<�����.��!r��ӑЅ�ܠ����>!�.u�r(u<"h�H�!n�����,��u�k1��)�疕��y����&��_�$K��.y�e�jQ����r�~ǣ��^����	�Wɟ,v�����ahoG�d[���G,�?%�[%���hڄWB���.kW4����oc���R�Gd
�5����]s���
��W�a��v��O��cr3oJ3pM�ֵga�9�$
�\�;n������O,Ѱ�
q6��a��!RZ�)������"�C�A!_�������1����~��|��(NP̒f�fg���\��W��4���Nf��m�S�~�C�;K�[2ժ�ԯ�s��"�*�l�Ŋ�V�+I(�@�K0��/IᆈT�U̵���詋s �� @����c��ӎN8�;��MS�,��U�N�m�e�ZeZ�F
ߤ\��>����n^�OU,�D[6��Z}��n���6�o����u�:��oA����6%�0͛�S֓��Zy�?U7:D����k+���>��d,�ȃ��5}��B/�!��d���U��Ԇȇw��e[�ʞ?��0�O��bߖ�
�k��]6F��S
޹u{�~D�>�,t�$+��(���m���ZԾ��ַf��`gؚϞO|{&Cr�y^�uC9���2-�G�.1�%W#�Ǌ�*f��:S3���n�ӝZ�;mVs���k��6>�����B�\k�j��a�>�f��Z+�pC�O���m!��\\;�-t���P������o�S�:.
��Ցh̷r���ɾ���ef3���
N��asj�����i���[mƗ�T5���}�㾫7��$+���پ[z�O}�ߥ�d��o��C�I���̱�,�,���Ϩ�6L�+>E�ߘ�����We�Rױ*ֱq�c�(������R���y�cL� q*(�6���G��w.���������6=y�k1_�@�9�5���ӥs��i1
��<��j�}�3K8�ꕣ;�ϋ�
yl��U��'a���I5����$�L_�_DC]�������nv�mK�y�@D?]~��.����w��H<g���
�`@>��X�_o�J��2��ts����<��y�[�����;5"-u�O�
��k֡�N�
��W�^}[o�}\�d�
�&y��8��=h�	者�Z�͒��K������~����<sB����Ϻ�o[_���h��*�*I�(D���d;?�q;���#�_	O���N� ���t�����M6��S�������2.&�z/�j�Au���%�����ͯl�����2��_�<t�i���c\�h�	Ť0n�}ܨ�j>�@M]k>���5�y����O�u��x�i�/zu�l>4�����>�bF	���@-&��o��Z>�r�����u���������77{����9a��vipT�����/ǑC&5ř���$��N���M����:��"�����������8��ⓞuײh��u�
����m/�8�l[Y�h�G>�B9�]�_=�Lp���-N�2kGG`�us����x^SM��0�y����Ovޤ��`�	k+�������]�W�q7��8�궔�iT���o��d]�Л��xe_Dw
���ٓ瞷[�׉|S�K�
�?�M��_�N>��g0�A�ѥY&�4�e6շ�k���K\G=N�W��83�8�	�5�C3:�6��q��
欕!�u�nvL6�k���N�?K;F��~8��_�NS���D���I��CI?���lz���uEo����>�c�$�)�"�YY�6��L�\��vbs1� ����0����e~�TC� e��nU��E?b�5�h�c�˫�������|������.��8R_��w~�����C�˞g,ڊ�;�]Q�}y���ޠ��w]�Wc��