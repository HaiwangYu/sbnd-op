# sbnd-op

```bash
lar -n 1 -c wcls-flash-dump.fcl -s rawdigit-opflash-art.root -o tmp.root
wirecell-img bee-flashes -o test.json tensor-apa-anode0.tar.gz
```

```bash
time lar -n 1 -c wcls-matching.fcl -s rawdigit-opflash-art.root -o tmp.root
```