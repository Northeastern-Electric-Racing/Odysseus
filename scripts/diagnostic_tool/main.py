import argparse
import sys
import os
from termcolor import cprint

from definitions import OPTIONS, Check
import checks.system_checks

# all checks are created here
# UID: all checks start with 0, and are 4 digits
# increment uid as new checks are created
CHECKS: dict[OPTIONS, list[Check]] = {
    OPTIONS.CAN: [  # calypso

    ],
    OPTIONS.GPS: [

    ],
    OPTIONS.HALOW: [

    ],
    OPTIONS.MQTT: [  # siren

    ],
    OPTIONS.DB: [

    ],
    OPTIONS.SYSTEM: [
        # checks.system_checks.TimeExampleCheck(0000)  # the example check
    ]
}


def handle_check(check: Check) -> None:
    '''
    Runs and prints results of a check.
    '''
    if (check.requires_root and os.geteuid() != 0):
        cprint(("Skipping " + check.short_name +
               ", it requires root"), file=sys.stdout)
        return

    worked, mes = check.run_check()
    if (worked):
        cprint((str(check.uid) + "--> "),
               attrs=["dark"], file=sys.stdout, end="")
        cprint((str(check.short_name) + "... OK"), "green", file=sys.stdout)
    else:
        cprint((str(check.uid) + " --> "),
               attrs=["dark"], file=sys.stderr, end="")
        cprint((check.short_name + "... FAILED"),
               "red", attrs=["bold"], file=sys.stderr)
        cprint(("   " + mes), "red", file=sys.stderr)
        followup = check.followup()
        if (followup != None):
            cprint(("   " + followup), "red", file=sys.stderr)


def get_choice_uids() -> list[int]:
    '''
    Search for valid UIDs in CHECKS and return them as a list.
    '''
    choices = []
    for key in CHECKS:
        for check in CHECKS[key]:
            choices.append(check.uid)

    return choices


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--option", "-o", help="Choose the option to debug, all if unspecified",
                        choices=OPTIONS, type=OPTIONS)
    parser.add_argument("--check", "-c", help="Run checks",
                        action="store_true")
    parser.add_argument("--uid", "-u", help="Run specific item, overrides all other selection params",
                        type=int, choices=get_choice_uids())

    args = parser.parse_args()

    if (args.uid != None):
        # run a specific UID, <1000 is a check
        if (args.uid < 1000):
            for key in CHECKS:
                for check in CHECKS[key]:
                    if (check.uid == args.uid):
                        handle_check(check)
    elif (args.check):
        # if option not specified, assume all
        if (args.option == None):
            #     cprint("Must choose option to check!", "red", file=sys.stderr)
            #     exit(1)
            for option in OPTIONS:
                for check in CHECKS[option]:
                    handle_check(check)
        else:
            for check in CHECKS[args.option]:
                handle_check(check)
