from .. import BufferedCommand, MeasureTask, OneshotCommand
import re

example_data = """BSSID         BW          TX bit rate        RX bit rate
=====================================================================
00:00:00:00:00:00     1M        0.33MBit/s(MCS 0)   0.33MBit/s(MCS 0)
=====================================================================
OK
"""


FETCH_THROUGHPUT_CMD = [
    "bmon",
    "-o",
    "format:fmt='$(attr:txrate:bytes) $(attr:rxrate:bytes)\n'",
    "-p",
    "bond0",
]
FETCH_RATE_CMD = ["cli_app", "show", "ap", "0"]
FETCH_RSSI_CMD = ["cli_app", "show", "signal"]


def _normalize_blocks(out):
    """Return a list of text blocks from bytes/str/iterable outputs."""
    if isinstance(out, bytes):
        return [out.decode(errors="replace")]
    if isinstance(out, str):
        return [out]
    try:
        return [
            b.decode(errors="replace") if isinstance(b, bytes) else str(b) for b in out
        ]
    except TypeError:
        return [str(out)]


def _parse_rssi(block):
    """Return the first RSSI float found in the block or None.
    Example RSSI:
    : MAC addr : 00:c0:ca:b1:9b:09  rssi     : -75          snr      : 27
    OK
    """
    # Prefer an explicit "rssi" key followed by a number (anywhere in the block)
    m = re.search(r"rssi\s*[:=]\s*([-+]?\d+(?:\.\d+)?)", block, re.IGNORECASE)
    if m:
        return float(m.group(1))
    return 0.0


class HalowRSSIMT(MeasureTask, OneshotCommand):
    def __init__(self, topic_root: str):
        self.topic_root = topic_root
        MeasureTask.__init__(self, 1)
        OneshotCommand.__init__(self, FETCH_RSSI_CMD, 1)

    def measurement(self):
        out = self.read()
        send_data = []

        for block in _normalize_blocks(out):
            if not block or not block.strip():
                continue
            value = _parse_rssi(block)
            if value is None:
                continue
            send_data.append((f"{self.topic_root}/Halow/RSSI", [value], "int"))

        return send_data


class HalowThroughputMT(MeasureTask, BufferedCommand):
    def __init__(self, topic_root: str):
        self.topic_root = topic_root
        MeasureTask.__init__(self, 1000)
        BufferedCommand.__init__(self, FETCH_THROUGHPUT_CMD)

    def measurement(self):
        items = self.read()
        send_data = []
        for item in items:
            item = item.strip("'").split(" ")
            data = [float(item[0].strip()), float(item[1].strip())]
            send_data.append((f"{self.topic_root}/HaLow/DataRate", data, "kb/s"))

        return send_data


class HalowMCSMT(MeasureTask, OneshotCommand):
    def __init__(self, topic_root: str):
        self.topic_root = topic_root
        MeasureTask.__init__(self, 500)
        OneshotCommand.__init__(self, FETCH_RATE_CMD, 450)

    def measurement(self):
        out = self.read()
        send_data = []
        for line in out:
            data_line = line.splitlines()[2]
            parsed_data_ap = float(data_line.split()[5][:-1].strip())
            parsed_data_sta = float(data_line.split()[3][:-1].strip())
            send_data.append(
                (f"{self.topic_root}/HaLow/ApMCS", [parsed_data_ap], "int")
            )
            send_data.append(
                (f"{self.topic_root}/HaLow/StaMCS", [parsed_data_sta], "int")
            )

        return send_data


def main():
    ex1 = HalowThroughputMT("TPU")
    print(ex1.measurement())

    ex2 = HalowMCSMT("TPU")
    print(ex2.measurement())

    ex3 = HalowRSSIMT("TPU")
    print(ex3.measurement())


if __name__ == "__main__":
    main()
