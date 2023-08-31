This repository contains the raw data as well as the post-processing scripts
for the paper:

<div align="center">
<h3>
“Implementing scalable matrix-vector products for the exact<br/>
diagonalization methods in quantum many-body physics”
</h3>
<p>by Tom Westerhout (@twesterhout) and Bradford L. Chamberlain (@bradcray)</p>

![paper](https://img.shields.io/badge/2308.XXXXX-arxiv?style=flat-square&logo=arxiv&logoColor=white&label=arXiv&labelColor=888888&color=blue)
[![build](https://img.shields.io/github/actions/workflow/status/twesterhout/paw-atm-2023/ci.yml?style=flat-square)](https://github.com/twesterhout/paw-atm-2023/actions/workflows/ci.yml)

</div>

> **Note:** If you are looking for the implementation of the _algorithms_
> described in the paper, you are in the wrong place. Have a look at
> https://github.com/twesterhout/lattice-symmetries instead.

## Reproducing the figures

Just run

```sh
nix build
```

and you're done. Our [GitHub
Actions](https://github.com/twesterhout/paw-atm-2023/actions) prove it.

## Reproducing the experiments

If you would like to reproduce the numerical experiments from the paper, things
get a little bit more complicated. In the following, we describe the necessary
components (both software and hardware) and show commands that run the
benchmarks.

### Software

The source code of the lattice-symmetries package can be found
[here](https://github.com/twesterhout/lattice-symmetries). The algorithms
described in the paper are all implemented in Chapel and can be found in the
[chapel/src](https://github.com/twesterhout/lattice-symmetries/tree/master/chapel/src)
folder. The source code of the supporting scripts is available in
[this](https://github.com/twesterhout/paw-atm-2023) repository.

To compile and run the code, the following two programs are required:

- [❄️ Nix](https://nixos.org/)
- [Apptainer (also known as Singularity)](https://apptainer.org/)

We have used Nix version 2.15.1 and Apptainer version 1.1.9-1.el8. Older
versions might work as well, but have not been tested.

Apptainer is commonly available on the supercomputing clusters, but Nix is not
as popular. We rely on the [Nixie project](https://github.com/nixie-dev/nixie/)
and ship a
[`nix`](https://github.com/twesterhout/lattice-symmetries/blob/master/nix)
shell script with the lattice-symmetries repository. It may be used instead of
a globally-installed `nix` executable, but it introduces a few constraints on
the system, namely:

- Linux operating system is assumed.
- User namespaces must be enabled.
- `$HOME/.local/share/nix` should not reside on a network drive and should have
  enough space. If this is not the case, one can create a symbolic link making
  `$HOME/.local/share/nix` point to a local scratch folder, e.g.,
  ```sh
  mkdir -p /scratch/nix && \
  ln --symbolic /scratch/nix $HOME/.local/share/
  ```

All the executables that we use for benchmarking are packaged as Apptainer
containers. To build the containers, one can use the following commands:

- For running on systems with Infiniband:

  ```sh
  nix build .\#distributed.ibv.BenchmarkBlockHashed
  nix build .\#distributed.ibv.BenchmarkStatesEnumeration
  nix build .\#distributed.ibv.BenchmarkMatrixVectorProduct
  ```

- For running on one node (but note that in this configuration, you will not be
  able to reproduce any of the scaling plots in the paper):

  ```sh
  nix build .\#distributed.smp.BenchmarkBlockHashed
  nix build .\#distributed.smp.BenchmarkStatesEnumeration
  nix build .\#distributed.smp.BenchmarkMatrixVectorProduct
  ```

Note that Nix creates a symbolic link called `result` pointing to the latest
build artifacts. To ease the subsequent running of the containers, we copy the
images to the `chapel/` folder of the lattice-symmetries package. For instance,

```sh
cd /path/to/cloned/lattice-symmetries/chapel
nix build .\#distributed.ibv.BenchmarkMatrixVectorProduct
# If you installed Nix properly
cp "$(readlink ./result)" BenchmarkMatrixVectorProduct.sif
# If you installed Nix via Nixie
cp "$HOME/.local/share/nix/root$(readlink ./result)" BenchmarkMatrixVectorProduct.sif
```

### Hardware

The experiments were performed on the Dutch National Supercomputer called
[Snellius](https://www.surf.nl/en/dutch-national-supercomputer-snellius). We
have used the "thin" partition (now called "rome") that, at the moment of
writing, consists of 504 nodes. Each node has 2 AMD Rome 7H12 CPUs with 64
cores/socket running at 2.6GHz (in total, 128 cores per node). The nodes have
16×16 GiB of DDR4 3200MHz memory. Each node has a single ConnectX-6 HDR100
port. In other words, the nodes are connected by a 100 Gb/s Infiniband network.

We expect that our experiments can be re-run on other clusters where nodes are
connected by Inifiniband network, but cannot guarantee that the exact same
scaling behavior will be achieved.

### Running the benchmarks

All our benchmarks were run using the Slurm scheduling system. An [example Slurm
script](./example-slurm-job.sh) is provided, but we do not expect it to be usable as is on clusters
other than Snellius.

The command to benchmark the matrix-vector product for a system of size
`chainLength` on `numLocales` nodes is:

```
set +x
srun --mpi=pmix -N $numLocales -n $numLocales apptainer exec \
  BenchmarkMatrixVectorProduct.sif BenchmarkMatrixVectorProduct \
  --numLocales $numLocales \
  --kHamiltonian data/heisenberg_chain_${chainLength}_symm.yaml \
  --kDisplayTimings=true
```

Similar commands can be run to benchmark the states enumeration and the
conversion between block- and hash-distributed arrays.

The executables write timings of various operations to standard output which
are then accumulated by Slurm into a `slurm-${SLURM_JOB_ID}.out` file. Multiple
commands may be run within one Slurm job.

### Post-processing the results

There is a [`crawl.py`](./crawl.py) script that may be used to collect results
from various Slurm output files into a `timings.csv` file.
[`analyze.py`](./analyze.py) file may then be used to extract the relevant data
for the plotting scripts.

We provide a [`flake.nix`](./flake.nix) file that specifies all the required
dependencies for running the scripts:

```console
$ cd /path/to/cloned/paw-atm-2023
$ nix develop
$ # copy all slurm-*.out files to data/lattice-symmetries
$ # (and remove the existing files if you don't want the scripts to use them)
$ python3 crawl.py
$ python3 analyze.py
```

### Plotting the results

Plotting scripts are also provided:

```console
$ cd /path/to/cloned/paw-atm-2023
$ nix develop
$ gnuplot plot-blockHashed.gnu
$ gnuplot plot-enumerateStates.gnu
$ gnuplot plot-matrixVectorProduct.gnu
```

### Benchmarking against SPINPACK

We compare the performance of lattice-symmetries against SPINPACK which we
consider the current state of the art among the open source exact
diagonalization codes.

To make the sure that our use of Nix or Apptainer does not negatively affect
the performance of SPINPACK, we compile SPINPACK using the software
pre-installed on Snellius.

We rely on the following modules:

```sh
module load 2023
module load GCC/12.3.0 OpenMPI/4.1.5-GCC-12.3.0
```

We use the latest (at the time of writing) version of SPINPACK:
[2.59d](https://www-e.uni-magdeburg.de/jschulen/spin/spinpack-2.59d.tgz). To
measure the execution time of the matrix-vector product, we use the
[spinpack-timings.patch](./data/spinpack/spinpack-timings.patch) patch that
adds the relevant timers.

The code is compiled using with a custom [Make_cfg.inc](./data/spinpack/Make_cfg.inc) that sets some configuration parameters:

- `CONFIG_MPI=4096` because we run tests on up to 32 nodes, and each node has 128 cores;
- `CONFIG_PTHREAD=128` because we have 128 cores per node;
- `-march=native -mtune=native` such that SPINPACK can use vectorization.

> **Note:** lattice-symmetries does not require setting `-march=native
-mtune=native` to make use of vectorized code paths and is thus more portable
> than SPINPACK. In lattice-symmetries, we also don't have to specify the
> number of cores or nodes during the compilation phase.

To run the code, we perform the following steps:

```sh
module load 2023
module load GCC/12.3.0 OpenMPI/4.1.5-GCC-12.3.0

# example_02 for the 40-spin system
# example_03 for the 42-spin system
cd data/spinpack/example_02
srun /path/to/spinpack/exe/spin --maxmem=0
```

The `--maxmem=0` flag forces SPINPACK to use its matrix-free representation for
the Hamiltonian. Otherwise SPINPACK would try to build a sparse matrix
representation of the Hamiltonian.

There is a [`spinpack.py`](./spinpack.py) script that extracts the timings from
the raw Slurm output files and prepares a `spinpack.csv` file that can be
consumed by the plotting scripts:

```sh
$ nix develop
# It is assumed that all the Slurm output files are in data/spinpack
$ python3 spinpack.py
$ gnuplot ./plot-spinpack.gnu
```
