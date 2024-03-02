from telemetry import measurement


@measurement(500)
def fetch_data():
    return [
        ("TPU/Example/Data1", ["114"], "C"),
        ("TPU/Example/Data1", ["1431242"], "D"),
        ("TPU/Example/Data1", ["1431242"], "Q"),
        ("TPU/Example/Data1", ["112343122"], "X"),
        ("TPU/Example/Data1", ["112341232"], "M"),
        ("TPU/Example/Data1", ["1413242"], "W"),
    ]


# fetch_data() # returns List[(str, [str], str)] in the format (topic, values, unit)
