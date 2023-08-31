# Generated automatically by configure 2.58b on Wed Jul 19 16:54:35 CEST 2023.
# found CC=gcc
# try option -std=c99 -D_POSIX_C_SOURCE=200112L to use c99 type _Complex
# tested successfully: MPICC=mpicc -DMPICH_IGNORE_CXX_SEEK -DCONFIG_MPI=1
# use option -pg or -gprof for gprof-analyzes
# best performance: CFLAGS+= -march=native -mtune=native
CC=gcc
MPICC=mpicc -DMPICH_IGNORE_CXX_SEEK -DCONFIG_MPI=4096
MPIEXEC?=mpiexec -np 2
CFLAGS= -Wall -Wno-unused-function -Wno-unknown-pragmas -std=gnu99 -O2 -funroll-loops -ftree-vectorize -march=native -mtune=native -DCONFIG_PTHREAD=128 -fopenmp
DFLAGS=
LIB= -fopenmp -lm 
# remove next line on make errors, its for HPC-speed
DFLAGS += -DCFG_CPUSET=2 -D_GNU_SOURCE
