##################################################################################
# Copyright (C) 2023 Sensoric Solutions Optic and Motion GmbH
#
# Subject to your compliance with these terms, you may use Sensoric Solutions software
# exclusively with Sensoric Solutions products. It is your responsibility to comply with
# third party license terms applicable to your use of third party software (including open
# source software) that may accompany Sensoric Solutions software.
#
# THIS SOFTWARE IS SUPPLIED BY SENSORIC SOLUTIONS "AS IS". NO WARRANTIES, WHETHER
# EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
# WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
# PARTICULAR PURPOSE.
#
# IN NO EVENT WILL SENSORIC SOLUTIONS BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
# INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
# WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF SENSORIC SOLUTIONS HAS
# BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.
##################################################################################

##################################################################################
# Demonstration of Measurement data receiving from Sensoric Solutions OMS 7
# optical sensor via Ethernet
#
# The software is only demonstration purpose. It contains neither sufficient
# exception and error handling nor a high-performance structure for productive use.
#
# Description:
#  - connect to Sensorsystem
#  - receive data until pressing a button
#  - writing all data in a csv result file
#  - plotting to signals
##################################################################################

# Import of needed Moduls
import socket
from struct import *
import os.path
from gmqtt import Client as MQTTClient

###############################-->SETUP<--##########################
PORT = 51000  # Datasend Port. See configuration (Default = 51000)
IP = "192.168.1.10"  # IP Address. See configuration (Default = 192.168.1.10)
CSV_NAME = "Measurement"  # Filename of the resulting csv file (without extension).
# A number for measurements will be automatically attached
SAMPLESTRUCT = 2  # Definition of Sample Struct. Supported are: 2 -> OMS 7; 3 -> OMS 4
VIEW_ID1 = 1  # Signal ID for Result Plotting
VIEW_ID2 = 2
####################################################################

PROTOCOL_VERSION = 1


## Class Stream
class Stream:
    ### Init
    def __init__(self):
        # Definitions of SAMPLESTRUCT
        # up from Python 3.7 dicts are ordered!
        # So this order must be exact that one from transmitted struct.
        # The Dist signals are transmitted in the unit 'mm', but used with
        # unit 'm', so a factor is used for recalculation  mm -> m.
        # The decode is for Python Module struct to decode data. For
        # details see https://docs.python.org/3/library/struct.html
        # Order is only for Plot
        if SAMPLESTRUCT == 2:
            self.Signals = (
                {  # name                  unit    Decode  Factor      Order(id)
                    "SampleTime": ("s", "f", 1, 1),
                    "VelXPoi": ("km/h", "f", 1, 2),
                    "VelYPoi": ("km/h", "f", 1, 3),
                    "VelAPoi": ("km/h", "f", 1, 4),
                    "AngSPoi": ("°", "f", 1, 5),
                    "DistAPoi": ("m", "l", 0.001, 6),
                    "RadiusPoi": ("m", "f", 1, 7),
                    "AccCPoi": ("m/s²", "f", 1, 8),
                    "Roll": ("°", "f", 1, 9),
                    "Pitch": ("°", "f", 1, 10),
                    "AccXHor": ("m/s²", "f", 1, 11),
                    "AccYHor": ("m/s²", "f", 1, 12),
                    "AccZHor": ("m/s²", "f", 1, 13),
                    "RateXHor": ("°/s", "f", 1, 14),
                    "RateYHor": ("°/s", "f", 1, 15),
                    "RateZHor": ("°/s", "f", 1, 16),
                    "VelX": ("km/h", "f", 1, 17),
                    "VelY": ("km/h", "f", 1, 18),
                    "VelA": ("km/h", "f", 1, 19),
                    "AngS": ("°", "f", 1, 20),
                    "DistA": ("m", "l", 0.001, 21),
                    "Radius": ("m", "f", 1, 22),
                    "AccC": ("m/s²", "f", 1, 23),
                    "AccX": ("m/s²", "f", 1, 24),
                    "AccY": ("m/s²", "f", 1, 25),
                    "AccZ": ("m/s²", "f", 1, 26),
                    "RateX": ("°/s", "f", 1, 27),
                    "RateY": ("°/s", "f", 1, 28),
                    "RateZ": ("°/s", "f", 1, 29),
                    "VelXSp": ("km/h", "f", 1, 30),
                    "VelYSp": ("km/h", "f", 1, 31),
                    "TriggerTime": ("s", "f", 1, 32),
                    "TempHead": ("°C", "f", 1, 33),
                    "Status": ("", "L", 1, 34),
                }
            )
        elif SAMPLESTRUCT == 3:
            self.Signals = (
                {  # name                  unit    Decode  Factor      Order(id)
                    "SampleTime": ("s", "f", 1, 1),
                    "VelAPoi": ("km/h", "f", 1, 4),
                    "DistAPoi": ("m", "l", 0.001, 6),
                    "Pitch": ("°", "f", 1, 10),
                    "AccXHor": ("m/s²", "f", 1, 11),
                    "AccZHor": ("m/s²", "f", 1, 13),
                    "RateYHor": ("°/s", "f", 1, 15),
                    "RateZHor": ("°/s", "f", 1, 16),
                    "VelA": ("km/h", "f", 1, 19),
                    "DistA": ("m", "l", 0.001, 21),
                    "AccX": ("m/s²", "f", 1, 24),
                    "AccZ": ("m/s²", "f", 1, 26),
                    "RateY": ("°/s", "f", 1, 28),
                    "RateZ": ("°/s", "f", 1, 29),
                    "VelASp": ("km/h", "f", 1, 43),
                    "TriggerTime": ("s", "f", 1, 32),
                    "TempHead": ("°C", "f", 1, 33),
                    "Status": ("", "L", 1, 34),
                }
            )
        else:
            raise Exception("Unknown SAMPLESTRUCT")
        self.__filenum = 0
        self.__filebasename = CSV_NAME
        self.__fileextension = ".csv"
        self.__DecodeStr = ""
        self.SigArray = []
        self.Factor = []
        i = 0
        for Signal in self.Signals:  # For all signals in SAMPLESTRUCT
            self.__DecodeStr += self.Signals[Signal][1]  # Add decode format
            self.SigArray.append([])  # Generate a place for the data
            self.Factor.append(self.Signals[Signal][2])  # Save factor for the signal
            i += 1

        self.buffer_count = 0
        self.buffer_threshold = 100  # Number of samples run before flushing to csv
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # crerate Socket

    ### Connect
    def connect(self, host, port):
        self.sock.connect((host, port))
        self.sock.setsockopt(
            socket.SOL_SOCKET, socket.SO_RCVBUF, 0xFFFFFF
        )  # increase receive buffer tcp window, otherwise it will hang, because buffer full and sensor wait until it is empty enough

    ### Receive
    def __receive(self, msglength):
        chunks = []
        bytes_recd = 0
        while bytes_recd < msglength:
            try:
                chunk = self.sock.recv(min(msglength - bytes_recd, 2048))
                if chunk == b"":
                    raise ConnectionError("Socket connection broken")
                chunks.append(chunk)
                bytes_recd = bytes_recd + len(chunk)
            except (ConnectionError, OSError) as e:
                print(f"Socket error: {e}. Attempting to reconnect...")
                self.reconnect()
                # After reconnect, try to receive again
                continue
        return b"".join(chunks)

    def reconnect(self):
        try:
            self.sock.close()
        except Exception:
            pass
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        connected = False
        while not connected:
            try:
                self.connect(IP, PORT)
                connected = True
                print("Reconnected to sensor.")
            except Exception as e:
                print(f"Reconnect failed: {e}. Retrying in 2 seconds...")
                import time

                time.sleep(2)

    ### Get Sequence Header
    def getHeader(self):
        headerArray = self.__receive(16)  # Header Length is 16Byte
        headerDecode = unpack("HHLLHH", headerArray)  # Format of Header
        self.Sync = headerDecode[0]
        self.Version = headerDecode[1]
        self.SeqNo = headerDecode[2]
        self.SeqLen = headerDecode[3]
        self.SampleStruct = headerDecode[4]
        self.SampleLen = headerDecode[5]
        if self.Sync != 0x5365:
            print("Incorrect Sync: expected 0x5365 received: ", self.Sync)
        if self.Version != PROTOCOL_VERSION:
            print(
                "Incorrect protocol version: expected ",
                PROTOCOL_VERSION,
                " received: ",
                self.Version,
            )
        if SAMPLESTRUCT != self.SampleStruct:
            print(
                "Incorrect Sample Struct: expected ",
                SAMPLESTRUCT,
                " received: ",
                self.SampleStruct,
            )

    ### Get Samples
    def getSamples(self):
        SamplesInSeq = int(
            (self.SeqLen - 4) / self.SampleLen
        )  # Calculate of Samples in struct
        for Sample in range(SamplesInSeq):
            dataArray = self.__receive(self.SampleLen)
            dataDecode = unpack(self.__DecodeStr, dataArray)  # decode received data
            for i in range(len(self.Factor)):
                self.SigArray[i].append(dataDecode[i] * self.Factor[i])  # use factor

    ## Close Connection
    def closeConnection(self):
        self.sock.close()

    ### check file number
    def __checkfile(self):
        loop = True
        while loop:
            if os.path.isfile(
                self.__filebasename + str(self.__filenum) + self.__fileextension
            ):
                self.__filenum += 1
            else:
                loop = False

    def connect_to_mqtt(
        self, client_id="sensoric_client", host="192.168.100.12", port=1883
    ):
        # initialize mqtt client
        self.mqtt_client = MQTTClient(client_id)
        # You can set up callbacks and connect here if needed
        # Example:
        self.mqtt_client.connect(host, port)

    def send_to_mqtt(self):
        import time
        from server_data_pb2 import ServerData

        if not hasattr(self, "mqtt_client"):
            print("MQTT client not initialized. Initializing now...")
            self.connect_to_mqtt()
        # Only send the most recent sample
        if len(self.SigArray[0]) == 0:
            return
        # Find the signal name and unit for the most recent value
        signal_names = list(self.Signals.keys())
        for idx, arr in enumerate(self.SigArray):
            value = arr[-1]
            signal_name = signal_names[idx]
            unit = self.Signals[signal_name][0]
            msg = ServerData()
            msg.unit = unit
            msg.time_us = int(time.time() * 1e6)
            msg.values.extend([value])
            topic = f"sensoric/{signal_name}/{unit}"
            try:
                self.mqtt_client.publish(topic, msg.SerializeToString(), qos=1)
            except Exception as e:
                print(f"MQTT publish failed: {e}. Attempting to reconnect...")
                self._mqtt_reconnect()
                try:
                    self.mqtt_client.publish(topic, msg.SerializeToString(), qos=1)
                except Exception as e2:
                    print(f"MQTT publish failed after reconnect: {e2}")

    def _mqtt_reconnect(
        self, client_id="sensoric_client", host="192.168.100.12", port=1883
    ):
        try:
            self.mqtt_client.disconnect()
        except Exception:
            pass
        print("Reconnecting MQTT client...")
        self.mqtt_client = MQTTClient(client_id)
        self.mqtt_client.connect(host, port)

    ### Flush buffer to csv and clear buffer
    def writefile(self, initial=False):
        self.__checkfile()
        mode = "w" if initial else "a"
        with open(
            self.__filebasename + str(self.__filenum) + self.__fileextension, mode
        ) as f:
            if initial:
                # Write header only on initial write
                signalText = ""
                unitText = ""
                for Signal in self.Signals:
                    signalText += Signal + ";"
                    unitText += "[" + self.Signals[Signal][0] + "]" + ";"
                f.write(signalText[:-1] + "\n")
                f.write(unitText[:-1] + "\n")
            # write data
            for i, v in enumerate(self.SigArray[0]):
                dataText = ""
                for j in range(len(self.Factor)):
                    dataText += str(self.SigArray[j][i]).replace(".", ",") + ";"
                f.write(dataText[:-1] + "\n")
        # Clear buffer after writing
        for arr in self.SigArray:
            arr.clear()


##################### Main
stream = Stream()  # create stream class
connected = False
while not connected:
    try:
        stream.connect(IP, PORT)  # and connect to Sensorsystem
        stream.connect_to_mqtt()
        connected = True
    except Exception as e:
        print(f"Initial connection failed: {e}. Retrying in 2 seconds...")
        import time

        time.sleep(2)

# Track if we've done the initial write
initial_write_done = False
buffer_counter = 0

while True:
    try:
        stream.getHeader()
        stream.getSamples()
        stream.send_to_mqtt()
        buffer_counter += 1
        if not initial_write_done:
            stream.writefile(initial=True)
            initial_write_done = True
        elif buffer_counter >= stream.buffer_threshold:
            stream.writefile(initial=False)
            buffer_counter = 0
    except (ConnectionError, OSError) as e:
        print(f"Error during data receive: {e}. Attempting to reconnect...")
        stream.reconnect()
    except Exception as e:
        print(f"Unexpected error: {e}")
