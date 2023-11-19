A script to check and monitor various things onboard Odysseus.  

To install dependencies:
`python -m pip install -r requirements.txt`

To run:  
`python -m main.py`  

Use `--help` for options.

Current types of diagnostics are:  
- Check --> True/False with followup info.  Run with `-c`

To add a new category:
- Add to `OPTIONS` enum
- Add the enum to CHECK dict in `main.py` as needed
- Add file to `./check` and add your checks.


To add a check:
- Create new check object in appropriate file in `./checks` with all parameters defined excpet UID.  Create logic for `run_check` and `followup` (optional).
- Declare check in the appropriate enum section of `CHECKS` in `main.py`, incrementing UID