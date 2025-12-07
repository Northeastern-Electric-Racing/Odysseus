from .. import BufferedCommand, MeasureTask, OneshotCommand
import re

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
    def __init__(self):
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
            send_data.append(("Base/HaLow/RSSI", [value], "int"))

        return send_data


def main():

    ex3 = HalowRSSIMT()
    print(ex3.measurement())


if __name__ == "__main__":
    main()
