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