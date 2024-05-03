# TPU Telemetry

## Setup
In order to run the virtual environment, cd into this directory and run the following commands:  
    - `python3 -m venv env`
    - `activate`

From Linux:  
    - `source env/bin/activate`

Then install the required dependencies: 
    - `pip install -r requirements.txt`

    
### Code regen
Before you can use the publishing script, you must use Protobuf (must have the compiler downloaded and included in PATH. see tutorial: https://protobuf.dev/getting-started/pythontutorial/, and latest protoc release: https://protobuf.dev/downloads/) to serialize the data. Move into the publishing directory:  
    - `cd ./telemetry  `

and run the command  
    - `protoc --python_out="." "server_data.proto"`

You're now prepared to work with the telemetry script:  
    - `python3 -m telemetry.publish`
    
    
## Edit TPU Install
TPU is installed differently.  In order to edit enter the `/usr/lib/tpu-telemetry/` directory and edit the python sources.  Ensure the system script is off (`/etc/init.d/S*tpu-telemetry stop`) and then run `tpu-telemetry` to test your edits.


## Add a measurement

3. See what file in `poll_data` you need to be in.  Try to match a current one.
1. See if you need a class.  If your datapoint can be sourced from an existing object or command, you should probably just add it to an existing class.  If you have a measurement procured from a different source and/or it needs its own frequency, make a new class.
2. See what class to inherit.  All inherits MeasureTask, but some data points are read from commands in a per-line mode (see BufferedCommand) and others are single commands run repetitively (see OneshootCommand).
3. Implement logic. For a custom class make sure you start from an example from other files, such as `example.py` for a plain MeasureTask or `can.py` for a buffered command, or `halow.py` for a oneshot command.
4. Add the class to the index in publish.py, by creating the task and storing it in TASKS in the run function.
