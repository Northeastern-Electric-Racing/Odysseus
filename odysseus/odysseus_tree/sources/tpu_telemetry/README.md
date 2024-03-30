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
