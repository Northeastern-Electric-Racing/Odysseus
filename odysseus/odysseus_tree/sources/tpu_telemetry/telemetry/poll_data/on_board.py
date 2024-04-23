from .. import MeasureTask
import psutil

class CpuTempMT(MeasureTask):
    def __init__(self):
         MeasureTask.__init__(self, 2000)

    def measurement(self):
        temps = psutil.sensors_temperatures(fahrenheit=False)
        for name, entries in temps.items():
            for entry in entries:
                line = "    %-20s %s °C (high = %s °C, critical = %s °C)" % (
                    entry.label or name,
                    entry.current,
                    entry.high,
                    entry.critical,
                )
        return [("TPU/OnBoard/CpuTemp", [str(entry.current)], "celsius")]
    
    
class CpuUsageMT(MeasureTask):
    def __init__(self):
         MeasureTask.__init__(self, 50)

    def measurement(self):
        cpu_usage = psutil.cpu_percent()
        return [("TPU/OnBoard/CpuUsage", [str(cpu_usage)], "percent")]



class BrokerCpuUsageMT(MeasureTask):
    def __init__(self):
         MeasureTask.__init__(self, 100)
         with open("/var/run/mosquitto.pid", "r") as file:
            pid = int(file.readlines()[0])
            print("Pid is", pid)
            self.process = psutil.Process(pid)


    def measurement(self):
        broker_cpu_usage = self.process.cpu_percent()
        return [("TPU/OnBoard/BrokerCpuUsage", [str(broker_cpu_usage)], "percent")]


class MemAvailMT(MeasureTask):
    def __init__(self):
         MeasureTask.__init__(self, 500)

    def measurement(self):
        mem_info = psutil.virtual_memory()
        mem_available = mem_info.available / (1024 * 1024)
        return [("TPU/OnBoard/MemAvailable", [str(mem_available)], "MB")]


def main():
    ex1 = CpuTempMT()
    print(ex1.measurement())

    ex2 = CpuUsageMT()
    print(ex2.measurement())

    ex3 = BrokerCpuUsageMT()
    print(ex3.measurement())

    ex4 = MemAvailMT()
    print(ex4.measurement())


if __name__ == "__main__":
    main()
