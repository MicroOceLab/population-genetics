mkdir -p data
mkdir -p results

cd data
mkdir -p query
mkdir -p reference
cd ..

docker build --file assets/python.Dockerfile --tag MicroOceLab/python:1.0 .
docker build --file assets/r.Dockerfile --tag MicroOceLab/r:1.0 .
docker pull quay.io/biocontainers/seqkit:2.10.0--h9ee0642_0
docker pull quay.io/biocontainers/mafft:7.221--0
docker pull quay.io/biocontainers/emboss:5.0.0--h362c646_6
docker pull quay.io/biocontainers/modeltest-ng:0.1.7--hf316886_3
docker pull quay.io/biocontainers/raxml-ng:0.9.0--h192cbe9_1