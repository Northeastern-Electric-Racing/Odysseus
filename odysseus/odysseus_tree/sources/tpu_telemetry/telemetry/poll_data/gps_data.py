from subprocess import check_output
from .. import measurement
import gps

session = gps.gps(mode=gps.WATCH_ENABLE)


@measurement(1000)
def fetch_data_location():
    try:
        tempLat = session.fix.latitude
        tempLong = session.fix.longitude
        return [("TPU/GPS/Location", [str(tempLat), str(tempLong)], "coordinate")]
    except Exception as e:
        print(f"Failed to fetch data: {e}")
        return []


@measurement(1000)
def fetch_data_speed():
    try:
        tempSpeed = session.fix.speed
        return [("TPU/GPS/GroundSpeed", [str(tempSpeed)], "knot")]
    except Exception as e:
        print(f"Failed to fetch data: {e}")
        return []


@measurement(1000)
def fetch_data_mode():
    try:
        tempMode = session.fix.mode
        return [("TPU/GPS/Mode", [str(tempMode)], "enum")]
    except Exception as e:
        print(f"Failed to fetch data: {e}")
        return []
