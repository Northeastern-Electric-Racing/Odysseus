# Wheel Buttons

This C application uses Unix domain sockets to send embedded button press signals to Nero. It is designed for inter-process communication on the same host, enabling efficient and secure transmission of button events.

## Features

- Sends button press signals via Unix domain sockets
- Simple and lightweight protocol for embedded systems
- Easy integration with other applications

## Usage

1. **Build the application:**
    ```sh
    make
    ```

2. **Run the sender:**
    ```sh
    TODO
    ```

3. **Run the receiver:**
    ```sh
    TODO
    ```

## Protocol

Button press signals are sent as simple messages over the socket. Each message contains the button identifier and its state.

## Requirements

- GCC or compatible C compiler
- Unix-like operating system

## License

MIT License
