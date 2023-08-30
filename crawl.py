import argparse
import copy
import os
import re
import sys
import glob
import numpy as np
import pandas as pd


def parse_srun_command(file, line):
    assert "srun" in line

    parser = argparse.ArgumentParser()
    parser.add_argument("--numLocales", type=int, required=True)
    parser.add_argument("--kRemoteBufferSize", type=int)
    parser.add_argument("--kCacheNumberBits", type=int)
    parser.add_argument("--kNumConsumerTasks", type=int)
    parser.add_argument("--kHamiltonian", type=str)
    parser.add_argument("--kFactor", type=int)
    args = parser.parse_known_args(line.split())[0].__dict__
    args["job"] = re.match(R".*/slurm-(.*).out", file).group(1)
    return args


def parse_timing(line):
    for function in [
        "matrixVectorProduct",
        "enumerateStates",
        "arrFromHashedToBlock",
        "arrFromBlockToHashed",
    ]:
        if function + ":" in line:
            m = re.match(R".*\[LOCALE([0-9]+)\]\s+" + function + R":\s+(.+)", line)
            return {"locale": int(m.group(1)), function: float(m.group(2))}
    return None


def average_timings_per_locale(timings, num_locales):
    functions = set()
    for t in timings:
        for key in t.keys():
            if key != "locale":
                functions.add(key)

    averaged = dict()
    for function in functions:
        ts = map(lambda t: t[function], filter(lambda t: function in t, timings))
        ts = np.asarray(list(ts), dtype=float)
        if len(ts) == 0:
            continue
        assert len(ts) == 1 or len(ts) == num_locales, (len(ts), num_locales)
        averaged[function] = np.mean(ts)

    return averaged


def process(file):
    results = []
    current = None
    timings = []

    with open(file, "r") as input:
        for line in input.readlines():
            if "PMIX ERROR" in line:
                continue
            if "error" in line.lower():
                sys.stderr.write("Skipping due to errors ...\n")
                return []
            if "srun --mpi=pmix" in line:
                if current is not None:
                    current.update(
                        average_timings_per_locale(timings, current["numLocales"])
                    )
                    results.append(current)
                current = parse_srun_command(file, line)
                timings = []

            t = parse_timing(line)
            if t is not None:
                assert current is not None
                timings.append(t)

        if current is not None:
            current.update(average_timings_per_locale(timings, current["numLocales"]))
            results.append(current)

        return results


def main():
    results = []

    for file in glob.glob("data/lattice-symmetries/slurm-*.out"):
        results += process(file)

    os.makedirs("data/processed", exist_ok=True)
    df = pd.DataFrame(results).to_csv(
        "data/processed/timings.csv", index=False, na_rep="nan"
    )


if __name__ == "__main__":
    main()
