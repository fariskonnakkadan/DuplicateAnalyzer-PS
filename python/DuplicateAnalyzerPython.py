import os
import hashlib
import threading
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor

def calculate_file_hash(file_path):
    hash_algorithm = hashlib.sha256()
    with open(file_path, "rb") as f:
        while chunk := f.read(8192):
            hash_algorithm.update(chunk)
    return hash_algorithm.hexdigest()

def process_files(folder_path, file_type, delete_duplicates, num_threads=4):
    if not os.path.exists(folder_path) or not os.path.isdir(folder_path):
        print(f"Invalid folder path: {folder_path}")
        return

    files = [os.path.join(root, file) for root, _, files in os.walk(folder_path) for file in files if file.endswith(file_type)]
    total_files = len(files)
    current_file_index = 0
    hashes = defaultdict(list)
    files_to_delete = []

    def process_file(file_path):
        nonlocal current_file_index
        hash_value = calculate_file_hash(file_path)
        hashes[hash_value].append(file_path)
        current_file_index += 1
        percent_complete = (current_file_index / total_files) * 100
        print(f"Processing: {current_file_index} of {total_files} - {percent_complete:.2f}%")
        print(progress_message, end="\r")
        if current_file_index == total_files:
            print()  # Print a newline when processing is completed

    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        for file in files:
            executor.submit(process_file, file)

    print("Processing completed.")

    if delete_duplicates:
        for hash_value, files_list in hashes.items():
            if len(files_list) > 1:
                files_to_delete.extend(files_list[1:])

        for file_to_delete in files_to_delete:
            os.remove(file_to_delete)
            print(f"Deleted: {file_to_delete}")

    else:
        duplicates_table = {}
        for hash_value, files_list in hashes.items():
            if len(files_list) > 1:
                duplicates_table[hash_value] = files_list

        if duplicates_table:
            print("Duplicate Files:")
            for hash_value, files_list in duplicates_table.items():
                print(f"Hash: {hash_value}")
                for file in files_list:
                    print(f"  {file}")
                print("=" * 40)
        else:
            print("No duplicate files found.")

if __name__ == "__main__":
    folder_path = input("Enter folder path: ")
    file_type = input("Enter file type (e.g., '.txt'): ")
    delete_duplicates = input("Delete duplicates? (y/n): ").lower() == "y"
    num_threads = int(input("Enter number of threads: "))
    process_files(folder_path, file_type, delete_duplicates, num_threads)
