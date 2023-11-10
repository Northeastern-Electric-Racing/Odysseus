from enum import Enum


class OPTIONS(Enum):
    CAN = "can"
    GPS = "gps"
    HALOW = "halow"
    MQTT = "mqtt"
    SYSTEM = "system"

    def __str__(self):
        return self.value


class Check():
    def __init__(self, short_name: str, uid: int, option: OPTIONS, long_name: str, requires_root=False):
        """Initialize a check.

        Args:
            short_name (str): Short (few words) name displayed when check passes
            uid (int): Incremented number to select the check in advanced mode
            option (OPTIONS): The option this check falls under
            long_name (str): A longer description of what this check does.
            requires_root (bool, optional): Does this check require sudouser. Defaults to False.
        """
        self.short_name = short_name
        self.uid = uid
        self.option = option
        self.long_name = long_name
        self.requires_root = requires_root

    def run_check(self) -> tuple[bool, str]:
        """Runs the check.

        Returns:
            tuple[bool, str]: 
                bool: True=passed, False=failed
                str: The error message to display if failed
        """
        pass

    def followup(self) -> str:
        """A followup check to pass more info about a failed problem.

        Returns:
            str: More info about the problem.
        """
        pass
