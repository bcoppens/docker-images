FROM python:3.10.2-slim-buster

RUN chmod 711 /mnt && \
  useradd -m runner && \
  apt-get update && \
  apt-get -y install --no-install-recommends \
     emboss=6.6.0+dfsg-7+b1 \
     gcc=4:8.3.0-1 \
     g++=4:8.3.0-1 \
     fontconfig=2.13.1-2 \
     libc6-dev=2.28-10 \
     make=4.2.1-1.2 \
     wget=1.20.1-1.1 \
     zlib1g-dev=1:1.2.11.dfsg-1 && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean && \
  # Judge dependencies
  pip install --no-cache-dir --upgrade pylint==2.12.2 jsonschema==3.2.0 pyshp==2.2.0 psutil==5.9.0 mako==1.1.6 pydantic==1.9.0 pyhumps==3.5.3 typing_inspect==0.7.1 && \
  # Exercise dependencies
  pip install --no-cache-dir --upgrade numpy==1.22.2 biopython==1.79 sortedcontainers==2.4.0 pandas==1.4.1

WORKDIR /tmp

RUN wget --progress=dot:giga -O fasta-36.3.8h.tar.gz https://github.com/wrpearson/fasta36/archive/refs/tags/v36.3.8h_04-May-2020.tar.gz && \
  tar xzf fasta-36.3.8h.tar.gz

WORKDIR /tmp/fasta36-36.3.8h_04-May-2020/src

RUN make -f ../make/Makefile.linux64 all && \
  sed -i "/XDIR/s#= .*#= /usr/bin#" ../make/Makefile.linux64 && \
  make -f ../make/Makefile.linux64 install

WORKDIR /tmp

RUN rm fasta-36.3.8h.tar.gz fasta36-36.3.8h_04-May-2020 -r && \
  fc-cache -f && \
  apt-get -y purge --autoremove gcc g++ libc6-dev make wget zlib1g-dev && \
  mkdir -p /home/runner/workdir && \
  chown -R runner:runner /home/runner && \
  chown -R runner:runner /mnt

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
