from .. import MeasureTask
import gps


class GpsMT(MeasureTask):
    def __init__(self):
         MeasureTask.__init__(self, 100)
         self.session = gps.gps(mode=gps.WATCH_ENABLE)


    def measurement(self):
        send_data = []
        if 0 == self.session.read() and self.session.valid:
            tempMode = self.session.fix.mode
            send_data.append(("TPU/GPS/Mode", [str(tempMode)], "enum"))
            
            if gps.isfinite(self.session.fix.speed):
                send_data.append(("TPU/GPS/GroundSpeed", [str(self.session.fix.speed)], "knot"))

            if gps.isfinite(self.session.fix.latitude) and gps.isfinite(self.session.fix.longitude) and self.session.fix.latitude != 0 and self.session.fix.longitude != 0:
                send_data.append(("TPU/GPS/Location", [str(self.session.fix.latitude), str(self.session.fix.longitude)], "coordinate"))

        return send_data


def main():
    ex = GpsMT()
    print(ex.measurement())


if __name__ == "__main__":
    main()
