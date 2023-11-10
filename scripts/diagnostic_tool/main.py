import argparse
import sys
import os
from termcolor import cprint

from definitions import OPTIONS, Check
import checks.system_checks

# all checks are created here
# UID: all checks start with 0, and are 4 digits
CHECKS: dict[OPTIONS, list[Check]] = {
    OPTIONS.CAN: [

    ],
    OPTIONS.GPS: [

    ],
    OPTIONS.HALOW: [

    ],
    OPTIONS.MQTT: [

    ],
    OPTIONS.SYSTEM: [
        checks.system_checks.TimeExampleCheck(0000)
    ]
}


def handle_check(check: Check) -> None:
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


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--option", "-o", help="Choose the option to debug",
                        choices=OPTIONS, type=OPTIONS)
    parser.add_argument("--check", "-c", help="Run checks",
                        action="store_true")
    parser.add_argument("--uid", "-u", help="Run specific item", type=int)

    args = parser.parse_args()

    if (args.uid != None):
        if (args.uid < 1000):
            for key in CHECKS:
                for check in CHECKS[key]:
                    if (check.uid == args.uid):
                        handle_check(check)
    elif (args.check):
        if (args.option == None):
            cprint("Must choose option to check!", "red", file=sys.stderr)
            exit(1)

        for check in CHECKS[args.option]:
            handle_check(check)
