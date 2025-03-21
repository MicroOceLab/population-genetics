mkdir -p data
mkdir -p results
docker pull alpine:3.21.3
docker pull quay.io/biocontainers/mafft:7.221--0
docker pull quay.io/biocontainers/emboss:5.0.0--h362c646_6
docker pull quay.io/biocontainers/modeltest-ng:0.1.7--hf316886_3