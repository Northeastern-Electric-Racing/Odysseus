from subprocess import check_output
FETCH_CMD = "bmon -o format:quitafter=1 -p can0"
#example = "can0 0 11024 0 40"

def fetch_data():
    try:
        out = check_output(FETCH_CMD.split(" "), shell=False).decode("utf-8")
        split = out.split(" ")
        data = [split[4].strip(), split[2].strip()]
        return [("TPU/Can/DataRate", data, "kb/s")]
    except Exception as e:
        print(f"Failed to fetch data: {e}")



def main():
    print(fetch_data())

if __name__ == "__main__":
    main()
    