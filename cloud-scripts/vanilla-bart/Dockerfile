FROM gcr.io/deeplearning-platform-release/r-cpu:latest

# Install system dependencies for Stan packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libopenblas-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure C++ Toolchain for Stan
RUN mkdir -p ~/.R && \
    echo "CXX14=g++" > ~/.R/Makevars && \
    echo "CXX14FLAGS=-O3 -fPIC" >> ~/.R/Makevars && \
    echo "CXX14STD=c++14" >> ~/.R/Makevars

# Install necessary R packages
RUN R -e "install.packages(c('remotes'), repos='https://cran.rstudio.com/')" || exit 1
RUN R -e "remotes::install_github('vdorie/stan4bart')" || exit 1
RUN R -e "remotes::install_github('vdorie/bartCause')" || exit 1
RUN R -e "install.packages(c('dbarts', 'googleCloudStorageR', 'here', 'readr', 'processx', 'dplyr'), repos='https://cran.rstudio.com/')" || exit 1

# Add any other packages your training needs

# Copy R scripts
COPY Train.R /
COPY train_data.csv /
COPY test_data.csv /

# Set working directory
WORKDIR /

# Set entrypoint to run Train.R
ENTRYPOINT ["Rscript", "Train.R"]