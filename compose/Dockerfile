FROM gcr.io/spins-retail-solutions/bitbucket:3.6
ENV PROJECT_DIR=/project DATA_DIR=/data LOG_DIR=/logs SCRIPT_DIR=/scripts

#install gcloud sdk
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
RUN mkdir -p /usr/local/gcloud
RUN tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz
RUN /usr/local/gcloud/google-cloud-sdk/install.sh

# this puts gcloud on the path for lines executed entrypoint
ENV PATH="/usr/local/gcloud/google-cloud-sdk/bin:${PATH}"

# this puts gcloud on the path for lines executed in the command
RUN echo 'export PATH=/usr/local/gcloud/google-cloud-sdk/bin:$PATH' >> ~/.bashrc

# install requirements
COPY requirements /requirements/
RUN env/bin/pip install --upgrade pip && \
    env/bin/pip install -r requirements/base.txt

RUN mkdir $DATA_DIR && \
    mkdir $LOG_DIR && \
    mkdir $SCRIPT_DIR

# copy in project and scripts
COPY project $PROJECT_DIR/ 
COPY scripts $SCRIPT_DIR/

WORKDIR $PROJECT_DIR
ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["bash", "/scripts/run-script.sh"]
