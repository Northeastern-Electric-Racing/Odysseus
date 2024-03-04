import asyncio

routines = {}


def measurement(freq: int):
    """
    Marks a measurement, takes a frequency (in ms) to repeat the measurement.
    """

    def wrapper(fn):
        routines[fn] = freq
        return fn  # return the function unmodified so manual calls still work

    return wrapper


async def set_interval(fn, interval: int, stop: asyncio.Event, *args, **kwargs):
    """
    Behaves *like* JS' `setInterval`:
    Run the function fn every interval milliseconds, and yield the result.
    Stop when the stop event is set.
    Uses the rest of the given args and kwargs for the function itself.
    """

    while not stop.is_set():
        yield fn(*args, **kwargs)
        await asyncio.sleep(interval / 1000)
