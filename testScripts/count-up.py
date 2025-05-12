import time
import sys

def count_up_every_0_3_seconds() -> None:
    count = 0
    while True:
        print(f"line: {count} | This particular line has been crafted as a straightforward test sentence to verify the successful processing and handling of text data within the context of file reading.", flush=True)
        count += 1
        time.sleep(0.3)

if __name__ == "__main__":
    count_up_every_0_3_seconds()