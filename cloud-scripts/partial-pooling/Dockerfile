FROM gcr.io/deeplearning-platform-release/r-cpu:latest

# ------------------------------
# Install rstanarm and friends
# ------------------------------
# Docker Hub (and Docker in general) chokes on memory issues when compiling
# with gcc, so copy custom CXX settings to /root/.R/Makevars and use ccache and
# clang++ instead

# Make ~/.R
RUN mkdir -p $HOME/.R

# $HOME doesn't exist in the COPY shell, so be explicit
COPY R/Makevars /root/.R/Makevars

# Install ggplot extensions like ggstance and ggrepel
# Install ed, since nloptr needs it to compile.
# Install all the dependencies needed by rstanarm and friends
# Install multidplyr for parallel tidyverse magic

RUN apt-get update && apt-get -y --no-install-recommends install \
    ed \
    clang \
    ccache \
    r-base-dev \
    build-essential \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    gfortran \
    libglpk-dev \
    libcairo2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('remotes'), repos='https://cran.rstudio.com/')" || exit 1
RUN R -e "install.packages(c('dbarts', 'googleCloudStorageR', 'here', 'readr', 'processx', 'rstan', 'rstanarm'), repos='https://cran.rstudio.com/')" || exit 1

# Copy R scripts
COPY Train.R /
COPY train_data.csv /

# Set working directory
WORKDIR /

# Set entrypoint to run Train.R
ENTRYPOINT ["Rscript", "Train.R"]