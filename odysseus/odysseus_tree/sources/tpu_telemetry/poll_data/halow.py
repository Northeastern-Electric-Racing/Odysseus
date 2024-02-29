from subprocess import check_output
example_data = """BSSID         BW          TX bit rate        RX bit rate
=====================================================================
00:00:00:00:00:00     1M        0.33MBit/s(MCS 0)   0.33MBit/s(MCS 0)
=====================================================================
OK
"""
example_RSSI = """---------------------------------------------------
RSSI                             : 0
CS_Cnt                           : 54
PSDU_Succ                        : 0
MPDU_Rcv                         : 0
MPDU_Succ                        : 0
SNR                              : 0
---------------------------------------------------
OK"""
FETCH_RSSI_CMD = "cli_app show stats simple_rx"
FETCH_RATE_CMD = "cli_app show ap 0"

def fetch_data_ApMCS():
    try:
        out = check_output(FETCH_RATE_CMD.split(" "), shell=False).decode("utf-8")
        data_line = out.splitlines()[2] 
        parsed_data = data_line.split()[5][:-1].strip()
        return [("TPU/HaLow/ApMCS", [parsed_data], "integer 0-10")]
    except Exception as e:
        print(f"Error fetching data: {e}")
        return []

def fetch_data_StaMCS():
    try:
        out = check_output(FETCH_RATE_CMD.split(" "), shell=False).decode("utf-8")
        data_line = out.splitlines()[2] 
        parsed_data = data_line.split()[3][:-1].strip()
        return [("TPU/HaLow/StaMCS", [parsed_data], "integer 0-10")]
    except Exception as e:
        print(f"Error fetching data: {e}")
        return []

def fetch_data_RSSI():

    try:
        out = check_output(FETCH_RSSI_CMD.split(" "), shell=False).decode("utf-8")
        split = out.splitlines()[1]
        data = split.split(":")[1].strip()
        return [("TPU/HaLow/RSSI", [data], "dbm")]
    except Exception as e:
        print(f"Error fetching data: {e}")
        return []

def fetch_data():
    return fetch_data_ApMCS() + fetch_data_StaMCS() + fetch_data_RSSI()

def main():
    print(fetch_data_ApMCS())
    print(fetch_data_StaMCS())
    print(fetch_data_RSSI())

if __name__ == "__main__":
    main()
    
