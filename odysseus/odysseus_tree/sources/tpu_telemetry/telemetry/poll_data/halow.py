from .. import BufferedCommand, MeasureTask, OneshotCommand

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


FETCH_THROUGHPUT_CMD = ["bmon","-r", "0.09", "format:fmt='$(attr:txrate:bytes) $(attr:rxrate:bytes)\n'", "-p", "wlan1"]
FETCH_RATE_CMD = ["cli_app","show", "ap", "0"]
FETCH_RSSI_CMD = ["cli_app", "show", "stats", "simple_rx"]

class HalowThroughputMT(MeasureTask, BufferedCommand):
    def __init__(self):
         MeasureTask.__init__(self, 100)
         BufferedCommand.__init__(self, FETCH_THROUGHPUT_CMD)

    def measurement(self):
        try:
            items = self.read()
            send_data = []
            for item in items:
                item = item.strip('\'').split(" ")
                data = [item[0].strip(), item[1].strip()]
                send_data.append(('TPU/HaLow/DataRate', data, 'kb/s'))
            
            return send_data
        except Exception as e:
            print(f"Failed to fetch data: {e}")
            return []


class HalowMCSMT(MeasureTask, OneshotCommand):
    def __init__(self):
         MeasureTask.__init__(self, 500)
         OneshotCommand.__init__(self, FETCH_RATE_CMD, 450)

    def measurement(self):
        try:
            out = self.read()
            for line in out:
                data_line = line.splitlines()[2]
                parsed_data_ap = data_line.split()[5][:-1].strip()
                parsed_data_sta = data_line.split()[3][:-1].strip()
                return [("TPU/HaLow/ApMCS", [parsed_data_ap], "int"), 
                      ("TPU/HaLow/StaMCS", [parsed_data_sta], "int")]
        except Exception as e:
            print(f"Error fetching data: {e}")
            return []

class HalowRSSIMT(MeasureTask, OneshotCommand):
    def __init__(self):
         MeasureTask.__init__(self, 500)
         OneshotCommand.__init__(self, FETCH_RSSI_CMD, 450)

    def measurement(self):
        try:
            out = self.read()
            for line in out:
                split = out.splitlines()[1]
                data = split.split(":")[1].strip()
                return [("TPU/HaLow/RSSI", [data], "int")]
        except Exception as e:
            print(f"Error fetching data: {e}")
            return []



def main():
    ex1 = HalowThroughputMT()
    print(ex1.measurement())

    ex2 = HalowMCSMT()
    print(ex2.measurement())

    ex3 = HalowRSSIMT()
    print(ex3.measurement())


if __name__ == "__main__":
    main()
