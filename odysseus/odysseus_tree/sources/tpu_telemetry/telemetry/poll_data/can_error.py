import asyncio
import can   
from .. import task

class ReadMessage: 
    def __init__(self, limit: int = 20) -> None:
        self.buffer: list[str] = []
        self.bus = can.interface.Bus(channel='can0', bustype='socketcan_native')
        self.limit = limit

        task(asyncio.create_task(self._streamer))
    
     
    def _streamer(self):
        for msg in self.bus:
            if len(self.buffer) > self.limit:
                self.buffer.clear()
            if msg.is_error_frame:
                self.buffer.append(msg)

    def read(self):
        tmp = self.buffer
        self.buffer = []
        return tmp

reader = ReadMessage()

def fetch_can_error():
    msgs = reader.read()
    list = []
    for msg in msgs:
        list.append(("TPU/Can/CanError", [str(msg)], "raw can msg"))
    return list

def main():
    print(fetch_can_error())

if __name__ == "__main__":
    main()
