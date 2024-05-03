from .. import BufferedCommand, MeasureTask


# read in 1/10 a second increments
FETCH_CMD = ["bmon","-o", "format:fmt='$(attr:txrate:bytes) $(attr:rxrate:bytes)\n'", "-p", "can0" ]
class CanMT(MeasureTask, BufferedCommand):
    def __init__(self):
         MeasureTask.__init__(self, 1000)
         BufferedCommand.__init__(self, FETCH_CMD)

    def measurement(self):
        items = self.read()
        send_data = []
        for item in items:
            item = item.strip('\'').split(" ")
            data = [item[0].strip(), item[1].strip()]
            send_data.append(('TPU/Can/DataRate', data, 'kb/s'))
        
        return send_data
        


def main():
    ex = CanMT()
    print(ex.measurement())


if __name__ == "__main__":
    main()