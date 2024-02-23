
import psutil, sys

# fetch_data() -> List[(str, [str], str)]

def fetch_data():
    return[fetch_cpu_temperature(), fetch_cpu_usage(), fetch_broker_cpu_usage(), fetch_available_memory()]
    


# CPU Temp
def fetch_cpu_temperature():
    temps = psutil.sensors_temperatures(fahrenheit=False)
    
    if not temps:
        sys.exit("can't read any temperature")
    for name, entries in temps.items():
        for entry in entries:
            line = "    %-20s %s °C (high = %s °C, critical = %s °C)" % (
                entry.label or name,
                entry.current,
                entry.high,
                entry.critical,
            )
    
    return[("  TPU/OnBoard/CpuTemp", [entry.current], "celsius")]

# CPU Usage 
def fetch_cpu_usage():
    try:
        cpu_usage = psutil.cpu_percent()
        return[("TPU/OnBoard/CpuUsage", [cpu_usage], "percent")]
    except Exception as e:
        print(f"Error fetching CPU usage: {e}")
        return None

# CPU usage of nanomq process
def fetch_broker_cpu_usage():
    try:
        with open('/var/run/nanomq_br.pid', 'r') as file:
            pid = int(file.read())
            process = psutil.Process(pid)
            broker_cpu_usage = process.cpu_percent()
        return[("TPU/OnBoard/BrokerCpuUsage", [broker_cpu_usage], "percent")]
    except Exception as e:
        print(f"Error fetching nanomq broker CPU usage: {e}")
        return None

# CPU available memory
def fetch_available_memory():
    try:
        mem_info = psutil.virtual_memory()
        mem_available = mem_info.available / (1024 * 1024)  
        return[("TPU/OnBoard/MemAvailable", [mem_available], "MB")]
    except Exception as e:
        print(f"Error fetching available memory: {e}")
        return None
    
def main():
    print(fetch_data())

if __name__ == "__main__":
    main()