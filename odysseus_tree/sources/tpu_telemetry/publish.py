from telemetry.publish import start_task
from telemetry.poll_data import can, halow, on_board, gps_data

TOPIC_ROOT = "TPU"

TASKS = [
    can.CanMT(TOPIC_ROOT),
    # environment.EnvironmentMT() # commented out bc sensor is currently broken
    halow.HalowThroughputMT(TOPIC_ROOT),
    halow.HalowMCSMT(TOPIC_ROOT),
    halow.HalowRSSIMT(TOPIC_ROOT),
    on_board.CpuTempMT(TOPIC_ROOT),
    on_board.CpuUsageMT(TOPIC_ROOT),
    on_board.BrokerCpuUsageMT(TOPIC_ROOT),
    on_board.MemAvailMT(TOPIC_ROOT),
    gps_data.GpsMT(TOPIC_ROOT),
]


def main():
    start_task(TASKS)


if __name__ == "main":
    main()
