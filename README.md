# sbnd-op

```bash
# in gpvm SL7 container
source /exp/sbnd/app/users/yuhw/wcp-porting-img/sbnd/setup.sh
```

## run matching
```bash
lar -n 1 -c wcls-matching.fcl -s lynn-sim.root -o tmp.root
./merge-upload.sh <event-num>
```

## dump light info
```bash
lar -n 1 -c wcls-flash-dump.fcl -s input-moon.root -o tmp.root
wirecell-img bee-flashes -o test.json tensor-apa-anode0.tar.gz
```

# Haiwang's cheat sheet to compile `larwirecell` using local `wirecell` build
Initial setup
```bash
source /cvmfs/sbnd.opensciencegrid.org/products/sbnd/setup_sbnd.sh
setup sbndcode v09_91_02 -q e26:prof
setup mrb 

# cd to the dev folder, $MRB_TOP_BUILD
mrb newDev
source localProducts_larsoft_v09_91_02_e26_prof/setup

# to use local wirecell build
export WIRECELL_FQ_DIR=/exp/sbnd/app/users/yuhw/opt
export WIRECELL_INC=/exp/sbnd/app/users/yuhw/opt/include
export WIRECELL_LIB=/exp/sbnd/app/users/yuhw/opt/lib
path-prepend /exp/sbnd/app/users/yuhw/opt CMAKE_PREFIX_PATH
path-remove /cvmfs/larsoft.opensciencegrid.org/products/wirecell/v0_27_1/Linux64bit+3.10-2.17-e26-prof CMAKE_PREFIX_PATH

mrb g larwirecell # cloning code

# checkout dev source code
cd srcs/larwirecell
git remote add fork git@github.com:HaiwangYu/larwirecell.git
git fetch fork
git checkout -b qlmatch-ls991 remotes/fork/qlmatch-ls991 
# edit "ups/product_deps" if needed

mrbsetenv
mrb i -j 8
mrbslp
```

after that:
```bash
source /cvmfs/sbnd.opensciencegrid.org/products/sbnd/setup_sbnd.sh
setup sbndcode v09_91_02 -q e26:prof
source /exp/sbnd/app/users/yuhw/larsoft/v09_91_02/localProducts_larsoft_v09_91_02_e26_prof/setup
mrbsetenv
mrb i -j 8 #if want to rebuild 
mrbslp
```

zap re-build:
```bash
mrb z
mrbsetenv
mrb i -j 8
```