from subprocess import check_output
FETCH_CMD = "bmon -o format:quitafter=1 -p can0"

def fetch_data():
    try:
        out = check_output(FETCH_CMD.split(" "), shell=True)
        return [("TPU/Can/DataRate", [out], "kb/s")]
    except Exception as e:
        print(f"Failed to fetch data: {e}")



def main():
    print(fetch_data())

if __name__ == "__main__":
    main()