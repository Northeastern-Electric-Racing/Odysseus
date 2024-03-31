# open file to read error
from .. import measurement
def read_sensor_data(sensor_path):
    try:
        with open(sensor_path, 'r') as f:
            sensor_data = int(f.read().strip()) / 1000  
            return sensor_data
    except IOError:
        print("Error: Unable to read data from", sensor_path)
        return None

# get data from given path 
@measurement(1000)
def fetch_environmental_data():
    data = []

    temp_sensor_path = '/sys/class/hwmon/hwmon2/temp1_input'
    humidity_sensor_path = '/sys/class/hwmon/hwmon2/humidity1_input'

    temperature = read_sensor_data(temp_sensor_path)
    if temperature is not None:
        data.append(("TPU/Environment/Temperature", [temperature], "Celsius"))

    humidity = read_sensor_data(humidity_sensor_path)
    if humidity is not None:
        data.append(("TPU/Environment/Humidity", [humidity], "%"))

    return data

def main():
    print(fetch_environmental_data())

if __name__ == "__main__":
    main()
