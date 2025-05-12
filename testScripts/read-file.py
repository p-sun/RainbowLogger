import sys

def read_file_line_by_line(file_path: str) -> None:
    try:
        with open(file_path, 'r') as file:
            for line in file:
                print(line, end='')
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python read_file_by_line.py <file_path>")
    else:
        read_file_line_by_line(sys.argv[1])
