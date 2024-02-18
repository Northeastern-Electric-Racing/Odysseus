def fetch_data():
    topic = 'TPU/Example/Data1'
    value = '12'
    unit = 'TestUnit'
    return [(topic, [value], unit)]

fetch_data() # returns List[(str, [str], str)] in the format (topic, values, unit)