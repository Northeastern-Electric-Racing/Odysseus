
# required import
from definitions import OPTIONS, Check

# add any other imports here
import time


# name your check here, passing in Check as so
class TimeExampleCheck(Check):

    # change the various positional parameters to describe your check.
    # UID should be passed in as it is dictated at runtime.
    def __init__(self, uid: int):
        super().__init__("Is second even", uid, OPTIONS.SYSTEM,
                         "Uses python time to determine if the seconds since unix epoch are even.", requires_root=False)

    # run your check, see run_check docs for more info.
    def run_check(self):
        curr_time = int(time.time())
        if curr_time % 2 == 0:
            return True, ""
        else:
            return False, "Oh no your time ain't even!" + " Time: " + str(curr_time)

    # run a followup check if the check fails, completely optional but can be helpful in showing the user more info
    def followup(self):
        curr_time = time.time()
        if (curr_time % 2 == 0):
            return "Hmm... your time fixed itself!"
        else:
            return "After thorough investigation, your time is still odd"
