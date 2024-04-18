from .. import MeasureTask
import gps


class GpsMT(MeasureTask):
    def __init__(self):
         MeasureTask.__init__(self, 1000)
         self.session = gps.gps(mode=gps.WATCH_ENABLE)


    def measurement(self):
        try:
            send_data = []
            if 0 == self.session.read() and self.session.valid:
                tempMode = self.session.fix.mode
                send_data.append(("TPU/GPS/Mode", [str(tempMode)], "enum"))
                
                if gps.isfinite(self.session.fix.speed):
                    send_data.append(("TPU/GPS/GroundSpeed", [str(self.session.fix.speed)], "knot"))

                if gps.isfinite(self.session.fix.latitude) and gps.isfinite(self.session.fix.longitude):
                    send_data.append(("TPU/GPS/Location", [str(self.session.fix.latitude), str(self.session.fix.longitude)], "coordinate"))

            return send_data
        except Exception as e:
            print(f"Failed to fetch data: {e}")
            return []


def main():
    ex = GpsMT()
    print(ex.measurement())


if __name__ == "__main__":
    main()
