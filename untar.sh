#!/bin/bash

function usage {
    echo "usage:"
    echo -e "\t$0 tar-file-name [-d output-directory]"
    exit 1
}

if [[ "$#" -ne 1 && "$#" -ne 3 ]]; then
    echo "$0: invalid number of arguments." >&2
    usage
fi

# Parse arguments
filepath=$1; shift
d_flag=$1; shift
output_directory=$1; shift

# Validate arguments
if [[ ! -z "$d_flag" ]]; then
    if [[ "$d_flag" != "-d" ]]; then
        echo "$0: unknown option $d_flag." >&2
        usage
    fi

    if [[ -z "$output_directory" ]]; then
        echo "$0: missing -d option argument." >&2
        usage
    fi
fi

# Check file exists
if [[ ! -f "$filepath" ]]; then
    echo "$0: file '$filepath' does not exists." >&2
    exit 3
fi

# Set defaults
file=$(basename $filepath)
directory=$(dirname $filepath)

ext=$(echo "$file" | sed -E 's/^.*([.]tar[.]bz2|[.]tar[.]gz|[.]tar)$/\1/')
if [[ "$ext" == "$file" ]]; then
    echo "$0: unsupported archive type '${ext##*.}'." >&2 
    exit 10
fi

if [[ -z "$d_flag" ]]; then
    # Set output directory to filename without extension
    output_directory="$directory/$(basename $file $ext)"
fi

function mk_output_dir {
    echo "creating $output_directory directory..."
    mkdir -p $output_directory || exit 2
}

echo "extracting $ext archive to $output_directory directory..."
case "$ext" in
    ".tar")
        mk_output_dir
        tar -C "$output_directory" -xvf $filepath
        ;;
    ".tar.gz")
        mk_output_dir
        tar -C "$output_directory" -zxvf $filepath
        ;;
    ".tar.bz2")
        mk_output_dir
        tar -C "$output_directory" -zxvj $filepath
        ;;
esac
