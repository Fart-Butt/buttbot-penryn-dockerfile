# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.12
FROM --platform=linux/amd64 python:${PYTHON_VERSION}-slim-bullseye

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

#upgrade container
RUN apt update -y && apt upgrade -y
RUN pip install --upgrade pip

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

WORKDIR /
#ADD https://github.com/OpenMathLib/OpenBLAS.git /OpenBLAS
#RUN apt install -y build-essential

#WORKDIR /OpenBLAS
#RUN make -j$(nproc) USE_THREAD=1 && make PREFIX=/usr/local/openblas install

#volume for buttbot's logs folder
VOLUME /buttbot/logs

#install requirements for mysqlclient and install mysqlclient
RUN apt install -y python3-dev default-libmysqlclient-dev build-essential pkg-config ninja-build dh-autoreconf gcc && python -m pip install -U pip setuptools wheel mysqlclient

#RUN python -m pip install blis
RUN python -m pip install --no-binary :all: "spacy-legacy>=3.0.11,<3.1.0"
RUN python -m pip install --no-binary :all: "spacy-loggers>=1.0.0,<2.0.0"
RUN python -m pip install --no-binary :all: "cymem>=2.0.2,<2.1.0"
RUN python -m pip install --no-binary :all: "preshed>=3.0.2,<3.1.0"
RUN BLIS_ARCH="generic" python -m pip install --no-binary :all: "thinc>=8.3.4,<8.4.0"

#download trained model
#for buttbot and decomposer
RUN python -m spacy download en_core_web_lg && python -m spacy download en_core_web_trf

#cd
WORKDIR /buttbot

#copy requirements to /app
ADD https://github.com/Fart-Butt/discordbot.git .

#load rest of buttbot's requirements
RUN python -m pip install -r requirements.txt

# Switch to the non-privileged user to run the application.
USER appuser

# Run the application.
CMD python3 /buttbot/discordbot.py