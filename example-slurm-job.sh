#!/bin/bash
#SBATCH -p thin --time 01:00:00
#SBATCH -n 64 -c 128
#SBATCH --exclusive
#SBATCH --exclude=tcn377
#SBATCH -J "64_matrixVectorProduct"

set -x

export GASNET_BACKTRACE=1
export GASNET_PHYSMEM_MAX='167 GB'

numLocales=$SLURM_JOB_NUM_NODES
remoteBufferSize=10000
cacheNumberBits=26
numConsumerTasks=24

# Benchmarking the matrix-vector product
for chainLength in 40 42; do
  srun --mpi=pmix -N $numLocales -n $numLocales apptainer exec \
    BenchmarkMatrixVectorProduct.sif BenchmarkMatrixVectorProduct \
    --numLocales $numLocales \
    --kHamiltonian data/heisenberg_chain_${chainLength}_symm.yaml \
    --kDisplayTimings=true \
    --kNumConsumerTasks=$numConsumerTasks \
    --kRemoteBufferSize=$remoteBufferSize \
    --kCacheNumberBits=$cacheNumberBits \
    --kFactor=$numLocales
done

# Benchmarking the conversion between array formats
# for chainLength in 40 42; do
#   srun --mpi=pmix -N $numLocales -n $numLocales apptainer exec \
#     ../BenchmarkBlockHashed.sif BenchmarkBlockHashed \
#     --numLocales $numLocales \
#     --kHamiltonian data/heisenberg_chain_${chainLength}_symm.yaml \
#     --kDisplayTimings=true
# done
