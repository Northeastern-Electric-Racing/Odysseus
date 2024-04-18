from abc import ABC, abstractmethod
import asyncio
from subprocess import PIPE, Popen
import subprocess
import threading
from time import sleep

class MeasureTask(ABC):
    def __init__(self, freq):
        self.interval = freq

    @abstractmethod
    def measurement(self) -> tuple[str, list[str], str]:
        """
        returns (str, [str], str) in the format (topic, [values], unit)
        """
        pass

    async def set_interval(self, stop: asyncio.Event):
        """
        Behaves *like* JS' `setInterval`:
        Run the function fn every interval milliseconds, and yield the result.
        Stop when the stop event is set.
        Uses the rest of the given args and kwargs for the function itself.
        """

        while not stop.is_set():
            measure = self.measurement()
            if measure is None:
                yield []
            else:
                yield measure
            await asyncio.sleep(self.interval / 1000)


class BufferedCommand:
    """
    Buffer a command's output into a list, that can be read
    on demand.
    """

    def __init__(self, command: list[str], limit: int = 20) -> None:
        """
        Construct a BufferedCommand.
        """
        self.process = Popen(command, stdout=PIPE, text=True, bufsize=1)

        self.buffer = ItemStore(limit=limit)

    def __deinit__(self):
        self.process.kill()

    def streamer(process, buffer):
        if process.poll() is None:
            for line in process.stdout:
                buffer.add(line)
    
    def get_thread(self):
        return threading.Thread(target=BufferedCommand.streamer, args=(self.process, self.buffer,), daemon=True)

    def read(self) -> list:
        return self.buffer.getAll()

    
class OneshotCommand:
    """
    Rerun oneshot commands on a frequency in a thread.
    Use for any commands which have the potential to hang.
    """
    def __init__(self, command: list[str], runFreq: int, limit: int = 20, ) -> None:

        self.buffer: ItemStore = ItemStore(limit=limit)

        self.command = command

        self.runFreq = runFreq
    
    def __deinit__(self):
        self.process.kill()

    def streamer(command, buffer, runFreq):
        while True: 
            data = subprocess.run(args=command, text=True).stdout
            if not data:
                buffer.add(data)
            sleep(runFreq / 1000)
        
    def get_thread(self):
        return threading.Thread(target=OneshotCommand.streamer, args=(self.command, self.buffer, self.runFreq), daemon=True)
        
    def read(self) -> list:
        return self.buffer.getAll()





class ItemStore():
    """
    Thread safe store, when limit hits list will clear
    """
    def __init__(self, limit: int):
        self.lock = threading.Lock()
        self.items = []
        self.limit = limit

    def add(self, item) -> None:
        if len(self.items) >= self.limit:
            self.items.clear()

        with self.lock:
            self.items.append(item)

    def getAll(self):
        with self.lock:
            items, self.items = self.items, []
        return items