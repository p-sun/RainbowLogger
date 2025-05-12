def generate_large_file(filename: str, num_lines: int) -> None:
    with open(filename, 'w') as f:
        for i in range(num_lines):
            line = f"line: {i} | This particular line has been crafted as a straightforward test sentence to verify the successful processing and handling of text data within the context of file reading.\n"
            f.write(line)

if __name__ == "__main__":
    # num_lines = 239674  # Calculated number of lines to reach approximately 40 MB
    # num_lines = 299593  # Calculated number of lines to reach approximately 50 MB
    # num_lines = 359511  # Calculated number of lines to reach approximately 60 MB
    num_lines = 479349  # Calculated number of lines to reach approximately 80 MB
    generate_large_file("veryLargeFile.txt", num_lines)
