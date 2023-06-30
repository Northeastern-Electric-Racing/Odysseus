import asyncio
import websockets
from websockets.client import WebSocketClientProtocol

SERVER_IP = "192.168.0.147"
SERVER_PORT = 8765


async def receiver(websocket: WebSocketClientProtocol):
    """
    Prints incoming data.
    """
    while True:
        data = await websocket.recv()
        # Here is where the client can handle incoming data and send it somewhere
        print(data)


async def controller():
    """
    Opens a websocket connection.
    """
    async with websockets.connect(f"ws://{SERVER_IP}:{SERVER_PORT}", timeout=10, ping_interval=None) as websocket:
        asyncio.create_task(receiver(websocket))
        while True:
            # Here is where client code would exist. This would involve interacting with the 
            # control protocol on the server to perform certain actions.
            # Currently just turning off and on data on a cycle
            await websocket.send("start")
            await asyncio.sleep(10)
            await websocket.send("stop")
            await asyncio.sleep(10)


if __name__ == "__main__":
    asyncio.run(controller())
