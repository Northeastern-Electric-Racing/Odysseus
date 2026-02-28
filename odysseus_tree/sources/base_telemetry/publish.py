from telemetry.publish import start_task
from telemetry.poll_data import halow

TOPIC_ROOT = "BASE"

TASKS = [
    halow.HalowRSSIMT(TOPIC_ROOT),
]


def main():
    start_task(TASKS)


if __name__ == "main":
    main()
