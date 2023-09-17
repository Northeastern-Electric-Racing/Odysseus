import websocket
import time
import ssl

# Callback for handling WebSocket open event
def on_open(ws):
    print("Started")
    
    while True:
        time.sleep(5)
        ws.send("Sending message to test topic!")

# Callback for handling WebSocket message event
def on_message(ws, message):
    print("Received message: {}".format(message))

# Callback for handling WebSocket error event
def on_error(ws, error):
    print("Error encountered: {}".format(error))

# Callback for handling WebSocket close event
def on_close(wsapp, close_status_code, close_msg):
    print("WebSocket connection closed.")
    
    if (close_status_code):
        print("Closing status code: " + close_status_code)
    if (close_msg):
        print("Closing message: " + close_msg)

# Define the WebSocket server URL
websocket_url = "wss://127.0.0.1:3000"

# Creating WebSocket connection object and attaching event handlers
ws = websocket.WebSocketApp(
    websocket_url,
    on_open=on_open,
    on_message=on_message,
    on_error=on_error,
    on_close=on_close
)

# Start the WebSocket connection
ws.run_forever(sslopt={"cert_reqs": ssl.CERT_NONE})
