# Use Ubuntu 16.04 LTS
FROM ubuntu:16.04

# Pre-cache neurodebian key
COPY docker/files/neurodebian.gpg /root/.neurodebian.gpg

MAINTAINER Sebastien Tourbier <sebastien.tourbier@alumni.epfl.ch>


## Install miniconda2 and multiscalebrainparcellator dependencies

RUN apt-get update && apt-get -qq -y install npm curl bzip2 && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && apt-get -qq -y install nodejs && \
    npm install -g bids-validator && \
    curl -sSL http://neuro.debian.net/lists/xenial.us-ca.full >> /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key add /root/.neurodebian.gpg && \
    (apt-key adv --refresh-keys --keyserver hkp://ha.pool.sks-keyservers.net 0xA5D32F012649A5A9 || true) && \
    curl -sSL https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -bfp /opt/conda && \
    rm -rf /tmp/miniconda.sh

ENV PATH /opt/conda/bin:$PATH

RUN conda install -y python=2.7.15 && \
    conda update conda && \
    conda clean --all --yes

RUN conda config --add channels conda-forge
RUN conda config --add channels aramislab

# RUN conda install -y pyqt=5.6.0
#RUN conda install -y pyqt=4

RUN conda install -y scipy=1.1.0
RUN conda install -y sphinx=1.5.1
RUN conda install -y traits=4.6.0
RUN conda install -y dateutil=2.4.1
RUN conda install -y certifi=2018.4.16
#RUN conda install -y patsy=0.4.1
#RUN conda install -y statsmodels=0.8.0
RUN conda install -y statsmodels=0.8.0
RUN conda install -y nose=1.3.7
RUN conda install -y pydot=1.2.3
# RUN conda install -y traitsui=5.1.0
RUN conda install -y numpy=1.14
RUN conda install -y nipype=1.1.6
RUN conda install -y nibabel=2.3.0
RUN conda install -y graphviz=2.38.0
RUN conda install -c aramislab -y pybids
RUN conda install -c anaconda -y configparser=3.5.0
RUN conda install -c conda-forge python-dateutil=2.5.3
RUN conda clean --all --yes

# Installing Freesurfer
RUN curl -sSL https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.1/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.1.tar.gz | tar zxv --no-same-owner -C /opt \
    --exclude='freesurfer/trctrain' \
    --exclude='freesurfer/subjects/fsaverage_sym' \
    --exclude='freesurfer/subjects/fsaverage3' \
    --exclude='freesurfer/subjects/fsaverage4' \
    --exclude='freesurfer/subjects/cvs_avg35' \
    --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
    --exclude='freesurfer/subjects/bert' \
    --exclude='freesurfer/subjects/V1_average' \
    --exclude='freesurfer/average/mult-comp-cor' \
    --exclude='freesurfer/lib/cuda' \
    --exclude='freesurfer/lib/qt'

# Installing the Matlab R2012b (v8.0) runtime
# Required by the brainstem and hippocampal subfield modules in FreeSurfer 6.0.1
WORKDIR /opt/freesurfer
RUN curl "http://surfer.nmr.mgh.harvard.edu/fswiki/MatlabRuntime?action=AttachFile&do=get&target=runtime2012bLinux.tar.gz" -o "runtime2012b.tar.gz"
RUN tar xvf runtime2012b.tar.gz
RUN rm runtime2012b.tar.gz
# Make FreeSurfer happy
RUN apt-get install -y -qq tcsh bc

ENV FSL_DIR=/usr/share/fsl/5.0 \
    OS=Linux \
    FS_OVERRIDE=0 \
    FIX_VERTEX_AREA= \
    FSF_OUTPUT_FORMAT=nii.gz \
    FREESURFER_HOME=/opt/freesurfer
ENV SUBJECTS_DIR=$FREESURFER_HOME/subjects \
    FUNCTIONALS_DIR=$FREESURFER_HOME/sessions \
    MNI_DIR=$FREESURFER_HOME/mni \
    LOCAL_DIR=$FREESURFER_HOME/local \
    FSFAST_HOME=$FREESURFER_HOME/fsfast \
    MINC_BIN_DIR=$FREESURFER_HOME/mni/bin \
    MINC_LIB_DIR=$FREESURFER_HOME/mni/lib \
    MNI_DATAPATH=$FREESURFER_HOME/mni/data \
    FMRI_ANALYSIS_DIR=$FREESURFER_HOME/fsfast
ENV PERL5LIB=$MINC_LIB_DIR/perl5/5.8.5 \
    MNI_PERL5LIB=$MINC_LIB_DIR/perl5/5.8.5 \
    PATH=$FREESURFER_HOME/bin:$FSFAST_HOME/bin:$FREESURFER_HOME/tktools:$MINC_BIN_DIR:$PATH

# Add fsaverage
WORKDIR /opt/freesurfer/subjects/fsaverage
ADD . /bids_dataset/derivatives/freesurfer/fsaverage

WORKDIR /
