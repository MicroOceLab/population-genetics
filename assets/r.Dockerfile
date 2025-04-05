FROM rocker/r-ver:4.4

RUN R -e "install.packages('devtools')"
RUN R -e "library(devtools); install_version('ape', version = '5.8-1', repos = 'http://cran.us.r-project.org')"
RUN R -e "library(devtools); install_version('pegas', version = '1.3', repos = 'http://cran.us.r-project.org')"
RUN R -e "library(devtools); install_version('glue', version = '1.8.0', repos = 'http://cran.us.r-project.org')"
RUN R -e "library(devtools); install_version('stringr', version = '1.5.1', repos = 'http://cran.us.r-project.org')"

CMD ["cat", "/etc/os-release"]