# sbnd-op

```bash
lar -n 1 -c wcls-flash-dump.fcl -s input-moon.root -o tmp.root
wirecell-img bee-flashes -o test.json tensor-apa-anode0.tar.gz
```

```bash
lar -n 1 -c wcls-matching.fcl -s input-moon.root -o tmp.root
rm -rf data-279
mv data data-279
python merge-apa.py --inpath=data-279 --eventNo=279 --outpath=data
./zip-upload.sh
```

