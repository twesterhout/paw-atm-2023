verbose=3   # verbose output (default: 3, overrides option -vNUM)
#            #  +1 time+prec., +2 H-statistics, +4 time consuming checks,
#            #  +8 symmetry debugging, +16 disk-I/O, +32 H-elements,
xout=3 20     # x_p 3 output format 0=uncompressed, 3=compressed, x_max 10 components
#chkpt_mode=1  # 1:store checkpoints, 2,3:set up after crash
#chkpt_load=0 # last checkpoint before crash
# old: set memory limits in daten.i, also try --mca mpi_preconnect_mpi 1
# ToDo: maxfile will be replaced by maxmem and maxfile will be for disk usage only
# since 2017-01 maxmem for (vector+)matrix-memory/task again, maxfile for disk 
pew=2        # number of EWs for convergence proof 0..NEW-1
nev=0        # number of lowest eigenvectors nev=0..NEV
ne0=0        # offset of lowest eigenvectors ne0=0..NEW-1
max_ea=1     # proof for degeneracy max_ea>0
startvec=14   # 1=(1,0,0,...) 2=load(d0.vec=bin) 3=load(s0.vec=txt)
#              4=random 5=lowHdiag 6=xorshift ini+=startvec&~7
z_anisotropy=1.0   # 1.0 for the isotropic case (obsolete, use zN in .def)
xy_anisotropy=1.0  # 1.0 for the isotropic case (obsolete, use zN in .def)
newtime      # reset the internal clock
sisj=4       # bitpattern: 1 <sisj>; 2 <ss>; 4 <mrule>; 0: fast_diag_OP only
sym_lm=0     # 0=max(S(S+1))  1=max(J(J+1))  see doc/sym_tU.txt
sym_ud=+1     # spin-inversion (+1,-1,0=off), only used for nu==nd
sym_k= 0 
# 0 0 2 0 -9999999 1 # eigenvalues ki of lattice-symmetries (-n to skip n symmetries)
#            #   -999999 and below skips all symmetries, similar to SIGUSR2
#nud=7,33     # number of up and down spins, defines matrix size
nud=-21,+21
#nud=40,0
#nev=1
param= 1.0, 0, 0.0, 0.0, 0.25  # p1, p2, p3 ...  alternative mode: p1= 1.0\n p2=0.0
#TODO param= 1.0 2.2 0.0 1.2
a0
#    # a0=lanczos a2=2x2diag a4=fulldiag +8=test
#    #   +16=rekursiv_serial_algo(parallel version ToDo) 
#    #   +32=old_slow_parallel_ns (default will be auto switching 2013-04)
