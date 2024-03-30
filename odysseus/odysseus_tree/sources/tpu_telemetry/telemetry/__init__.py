import asyncio
from subprocess import Popen, PIPE

routines = {}
processes: list[Popen[str]] = []


def measurement(freq: int):
    """
    Marks a measurement, takes a frequency (in ms) to repeat the measurement.
    """

    def wrapper(fn):
        routines[fn] = freq
        return fn  # return the function unmodified so manual calls still work

    return wrapper


async def set_interval(fn, interval: int, stop: asyncio.Event, *args, **kwargs):
    """
    Behaves *like* JS' `setInterval`:
    Run the function fn every interval milliseconds, and yield the result.
    Stop when the stop event is set.
    Uses the rest of the given args and kwargs for the function itself.
    """

    while not stop.is_set():
        yield fn(*args, **kwargs)
        await asyncio.sleep(interval / 1000)


class BufferedCommand:
    """
    Buffer a command's output into a list, that can be read
    on demand.
    """

    def __init__(self, command: list[str], limit: int = 20) -> None:
        """
        Construct a BufferedCommand.
        """

        self.buffer: list[str] = []
        self.process = Popen(command, stdout=PIPE, text=True)
        processes.append(self.process)

        self.limit = limit

        asyncio.create_task(self._streamer)

    def _streamer(self):
        for line in self.process.stdout:
            if len(self.buffer) > self.limit:
                self.buffer.clear()

            self.buffer.append(line)

    def read(self):
        tmp = self.buffer
        self.buffer = []
        return tmp
