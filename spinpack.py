import glob
import itertools
import re
import numpy as np
import pandas as pd


def get_reference_time(size):
    df = pd.read_csv("data/processed/timings.csv")[
        ["kHamiltonian", "numLocales", "matrixVectorProduct"]
    ]
    df = df.loc[df["kHamiltonian"] == "data/heisenberg_chain_{}_symm.yaml".format(size)]
    num_locales = df["numLocales"].min()
    time = df.loc[df["numLocales"] == num_locales, "matrixVectorProduct"].min()
    return time


def select_system_size(df, size):
    return df.loc[df["system_size"] == size]


def process(file):
    system_size = None
    num_locales = None
    timings = []

    with open(file, "r") as input:
        for line in input.readlines():
            if "PWD=" in line:
                m = re.match(R".*PWD=/.*example_(.+)/(.+)", line)
                if m.group(1) == "02":
                    system_size = 40
                elif m.group(1) == "03":
                    system_size = 42
                else:
                    assert False

                num_locales = int(m.group(2))

            if "[TIMINGS]" in line:
                m = re.match(R"\[TIMINGS\] hamilton:\s(.*)", line)
                timings.append(float(m.group(1)))

    return [
        {"numLocales": num_locales, "system_size": system_size, "hamilton": t}
        for t in timings
    ]


def main():
    results = []
    for file in glob.glob("data/spinpack/slurm-*.out"):
        results += process(file)

    df = pd.DataFrame(results)

    for s in [40, 42]:
        selected = select_system_size(df, s).copy()
        ref_time = get_reference_time(s)
        selected["hamiltonSpeedup"] = ref_time / selected["hamilton"]
        # SPINPACK's matrix vector product is extremely noisy, i.e. timings
        # fluctuate considerably. So we take multiple measurements and average
        selected = selected.groupby("numLocales").mean(numeric_only=True)
        selected.to_csv("data/processed/spinpack_{}.csv".format(s), na_rep="nan")


if __name__ == "__main__":
    main()
