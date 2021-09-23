import os

import pyunpack
import py7zr


def get_all_files(path):
    # if given a single file, return that
    if os.path.isfile(path):
        return [path]

    if not os.path.isdir(path):
        print(f"WARNING: Invalid Path: {path}")
        return None

    file_paths = []
    for root, _, files in os.walk(path):
        for file in files:
            file_paths.append(os.path.join(root, file))
    return file_paths


def expand_all(path_array):
    print("expand_all()")
    print(path_array)


def main(path="."):
    """Execution starts here"""
    print("main()")

    path_array = get_all_files(path)
    expand_all(path_array)
    # https://github.com/audreyfeldroy/binaryornot
    # https://stackoverflow.com/questions/898669/how-can-i-detect-if-a-file-is-binary-non-text-in-python


if __name__ == "__main__":
    main("/tmp/test-extract")
