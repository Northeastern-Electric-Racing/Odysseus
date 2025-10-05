import socket
import os
import logging

SOCKET_PATH = "/tmp/wheel_buttons_socket"
BUFFER_SIZE = 256

def main():
    
    try:
        os.unlink(SOCKET_PATH)
    except OSError:
        if os.path.exists(SOCKET_PATH):
            raise
        
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    
    try:
        server.bind(SOCKET_PATH)
        server.listen(2)
        logging.info(f"Server listening on {SOCKET_PATH}")
        
        while True:
            logging.info("Waiting for a connection...")
            conn,addr = server.accept()
            logging.info("Connection established.")
            
            try:
                while True:
                    data = conn.recv(BUFFER_SIZE)
                    if not data:
                        logging.warning("No data received, closing connection.")
                        break
                    logging.info(f"Received: {data.decode('utf-8')}")
                    conn.send(b"ACK")
                    
            except Exception as e:
                logging.error(f"Error receiving data: {e}")
            finally:
                conn.close()
                
    except KeyboardInterrupt:
        logging.info("\nShutting down server...")
        
    finally:
        server.close()
        try:
            os.unlink(SOCKET_PATH)
        except OSError:
            pass
        
main()