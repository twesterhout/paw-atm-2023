import itertools
import numpy as np
import pandas as pd


def get_reference_time(df, function):
    num_locales = df["numLocales"].min()
    time = df.loc[df["numLocales"] == num_locales, function].min()
    return time


def select_system_size(df, size):
    return df.loc[
        df["kHamiltonian"] == "data/heisenberg_chain_{}_symm.yaml".format(size)
    ]


def analyze_results(df, size, func, speedup=True, blacklist=None, filter_fn=None):
    selected = select_system_size(df, size)
    if filter_fn is not None:
        selected = filter_fn(selected)
    selected = selected[["numLocales", func, "job"]]
    selected = selected.loc[selected[func].notna()]
    ref_time = get_reference_time(selected, func)
    if speedup:
        speedup_col = func + "Speedup"
        selected = selected.copy()
        selected[speedup_col] = ref_time / selected[func]
    if blacklist is not None:
        selected = selected.loc[~selected["job"].isin(blacklist)]
    if speedup:
        # NOTE: We take the max here, because some jobs were run with sub-optimial hyperparameters :(
        indices = selected[["numLocales", speedup_col]].groupby("numLocales").idxmax()
        selected = selected.loc[indices[speedup_col]]
    else:
        indices = selected[["numLocales", func]].groupby("numLocales").idxmin()
        selected = selected.loc[indices[func]]
    selected.to_csv("data/processed/{}_{}.csv".format(func, size), na_rep="nan")


def main():
    df = pd.read_csv(
        "data/processed/timings.csv",
        dtype={"kHamiltonian": str, "job": str, "default": np.float64},
    )

    for s in [40, 42]:
        # NOTE: Many jobs were run before a performance regression in
        # enumerateStates has been fixed. These jobs contain useful data for
        # the matrixVectorProduct operation, so we don't want to delete the
        # slurm files. Rerunning the jobs is undesirable either because of long
        # queueing times and limited CPU resources. Instead, we define a list
        # of jobs files that should be ignored here.
        # fmt: off
        blacklist = set(["3076365", "3076365", "3086823", "3086824", "3076437", "3075054", "3025507"])
        # fmt: on
        analyze_results(df, s, "enumerateStates", blacklist=blacklist)

    for s in [40, 42]:
        for f in ["arrFromBlockToHashed", "arrFromHashedToBlock"]:
            # NOTE: Similar to enumerateStates, we ignore some files
            blacklist = set(["3025507"])
            analyze_results(df, s, f, speedup=False, blacklist=blacklist)

    for s, r, k, b in [
        (40, 10000, 24, 26),
        (42, 10000, 24, 26),
        (44, 10000, 24, 26),
        (46, 10000, 24, 26),
    ]:
        # Select the right hyperparameters
        def filter_fn(df):
            return df.loc[
                (df["kRemoteBufferSize"] == r)
                & (df["kNumConsumerTasks"] == k)
                & (df["kCacheNumberBits"] == b)
            ].copy()

        analyze_results(df, s, "matrixVectorProduct", filter_fn=filter_fn)


if __name__ == "__main__":
    main()
