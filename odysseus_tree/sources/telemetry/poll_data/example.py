from .. import MeasureTask


class ExampleMT(MeasureTask):
    def __init__(self, topic_root: str):
        self.topic_root = topic_root
        MeasureTask.__init__(self, 1000)

    def measurement(self):
        return [
            (f"{self.topic_root}/Example/Data1", [114], "C"),
            (f"{self.topic_root}/Example/Data2", [1431242], "D"),
            (f"{self.topic_root}/Example/Data3", [1431242], "Q"),
            (f"{self.topic_root}/Example/Data4", [112343122], "X"),
            (f"{self.topic_root}/Example/Data5", [112341232], "M"),
            (f"{self.topic_root}/Example/Data6", [1413242], "W"),
        ]


def main():
    ex = ExampleMT("TPU")
    print(ex.measurement())


if __name__ == "__main__":
    main()
