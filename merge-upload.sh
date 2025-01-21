rm -r data
python merge-apa.py --inpath=data-sep --outpath=data --eventNo=${1}
rm -f upload.zip
zip -r upload data
./upload-to-bee.sh upload.zip