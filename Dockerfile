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
RUN python -m pip install --no-binary :all: "murmurhash>=1.0.2,<1.1.0"
RUN python -m pip install --no-binary :all: "cymem>=2.0.2,<2.1.0"
RUN python -m pip install --no-binary :all: "preshed>=3.0.2,<3.1.0"
RUN python -m pip install "numpy>=2.0.0,<3.0.0"
RUN python -m pip install pytest
RUN python -m pip install "hypothesis>=4.0.0,<7.0.0"
RUN python -m pip install --no-binary :all: "blis>=1.3.0,<1.4.0"
RUN python -m pip install --no-binary :all: "srsly>=2.4.0,<3.1.0"
RUN python -m pip install --no-binary :all: "wasabi>=0.8.1,<1.2.0"
RUN python -m pip install --no-binary :all: "catalogue>=2.0.4,<2.1.0"
RUN python -m pip install --no-binary :all: "confection>=0.0.1,<1.1.0"
RUN python -m pip install --no-binary :all: "ml_datasets>=0.2.0,<0.3.0"
# Third-party dependencies
RUN python -m pip install --no-binary :all: "pydantic>=2.0.0,<3.0.0"
RUN python -m pip install --no-binary :all: "numpy>=2.0.0,<3.0.0"
RUN python -m pip install --no-binary :all: "packaging>=20.0"
# Development dependencies
RUN python -m pip install --no-binary :all: "cython>=3.0,<4.0"
RUN python -m pip install --no-binary :all: "hypothesis>=3.27.0,<6.149"
RUN python -m pip install --no-binary :all: "pytest>=5.2.0,!=7.1.0"
RUN python -m pip install --no-binary :all: "pytest-cov>=2.7.0,<8.0.0"
RUN python -m pip install --no-binary :all: "coverage>=5.0.0,<8.0.0"
RUN python -m pip install --no-binary :all: "flake8==5.0.4"
RUN python -m pip install --no-binary :all: "mypy>=1.5.0,<1.6.0"
# Executing notebook tests
RUN python -m pip install --no-binary :all: "ipykernel>=5.1.4,<7.2"
RUN python -m pip install --no-binary :all: "pydot"
RUN python -m pip install --no-binary :all: "graphviz"
RUN python -m pip install --no-binary :all: "nbconvert>=5.6.1,<7.17"
RUN python -m pip install --no-binary :all: "nbformat>=5.0.4,<5.11"
# Test to_disk/from_disk against pathlib.Path subclasses
RUN python -m pip install --no-binary :all: "pathy>=0.3.5"
RUN python -m pip install --no-binary :all: "black>=22.0,<23.0"
RUN python -m pip install --no-binary :all: "isort>=5.0,<6.0"

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