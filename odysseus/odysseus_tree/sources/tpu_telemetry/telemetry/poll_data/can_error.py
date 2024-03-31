
import can     

# seperate function so main function only gets called when there's an error
def receive_message():
    bus = can.interface.Bus(channel='can0', bustype='socketcan_native')
    for msg in bus:
        if msg.is_error_frame:
            return(msg)

def fetch_can_error():
    msg = receive_message
    return [("TPU/Can/CanError", [str(msg)], "raw can msg")]

def main():
    print(fetch_can_error())

if __name__ == "__main__":
    main()
