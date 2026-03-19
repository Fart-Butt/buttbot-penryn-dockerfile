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
RUN apt install -y python3-pip python3-dev default-libmysqlclient-dev build-essential pkg-config ninja-build dh-autoreconf gcc && python -m pip install -U pip setuptools wheel mysqlclient

#RUN python -m pip install blis
RUN python -m pip install "spacy-legacy>=3.0.11,<3.1.0"
RUN python -m pip install "spacy-loggers>=1.0.0,<2.0.0"
RUN python -m pip install "cymem>=2.0.2,<2.1.0"
RUN python -m pip install "preshed>=3.0.2,<3.1.0"
RUN python -m pip install "murmurhash>=1.0.2,<1.1.0"
RUN python -m pip install "cymem>=2.0.2,<2.1.0"
RUN python -m pip install -"preshed>=3.0.2,<3.1.0"
#compile numpy from source
ADD https://github.com/numpy/numpy.git ./
WORKDIR numpy
RUN pip3 install .

RUN python -m pip install pytest
RUN python -m pip install "hypothesis>=4.0.0,<7.0.0"
RUN python -m pip install "blis>=1.3.0,<1.4.0"
RUN python -m pip install "srsly>=2.4.0,<3.1.0"
RUN python -m pip install "wasabi>=0.8.1,<1.2.0"
RUN python -m pip install "catalogue>=2.0.4,<2.1.0"
RUN python -m pip install "confection>=0.0.1,<1.1.0"
RUN python -m pip install "ml_datasets>=0.2.0,<0.3.0"
# Third-party dependencies
RUN python -m pip install "pydantic>=2.0.0,<3.0.0"
RUN python -m pip install "packaging>=20.0"
# Development dependencies
RUN python -m pip install --no-binary :all: "cython>=3.0,<4.0"
RUN python -m pip install "hypothesis>=3.27.0,<6.149"
RUN python -m pip install "pytest>=5.2.0,!=7.1.0"
RUN python -m pip install "pytest-cov>=2.7.0,<8.0.0"
RUN python -m pip install "coverage>=5.0.0,<8.0.0"
RUN python -m pip install "flake8==5.0.4"
RUN python -m pip install "mypy>=1.5.0,<1.6.0"
# Executing notebook tests
RUN python -m pip install "ipykernel>=5.1.4,<7.2"
RUN python -m pip install "pydot"
RUN python -m pip install "graphviz"
RUN python -m pip install "nbconvert>=5.6.1,<7.17"
RUN python -m pip install "nbformat>=5.0.4,<5.11"
# Test to_disk/from_disk against pathlib.Path subclasses
RUN python -m pip install "pathy>=0.3.5"
RUN python -m pip install "black>=22.0,<23.0"
RUN python -m pip install "isort>=5.0,<6.0"
#------------ spacy continue ----------
RUN python -m pip install "ml_datasets>=0.2.0,<0.3.0"
RUN python -m pip install "murmurhash>=0.28.0,<1.1.0"
RUN python -m pip install "wasabi>=0.9.1,<1.2.0"
RUN python -m pip install "srsly>=2.4.3,<3.0.0"
RUN python -m pip install "catalogue>=2.0.6,<2.1.0"
RUN python -m pip install "typer-slim>=0.3.0,<1.0.0"
RUN python -m pip install "weasel>=0.4.2,<0.5.0"
# Third party dependencies
RUN python -m pip install "numpy>=2.0.0,<3.0.0"
RUN python -m pip install "requests>=2.13.0,<3.0.0"
RUN python -m pip install "tqdm>=4.38.0,<5.0.0"
RUN python -m pip install "pydantic>=1.7.4,!=1.8,!=1.8.1,<3.0.0"
RUN python -m pip install "jinja2"
# Official Python utilities
RUN python -m pip install "setuptools"
RUN python -m pip install "packaging>=20.0"
# Development dependencies
RUN python -m pip install "pre-commit>=2.13.0"
RUN python -m pip install "cython>=3.0,<4.0"
RUN python -m pip install "pytest>=5.2.0,!=7.1.0"
RUN python -m pip install "pytest-timeout>=1.3.0,<2.0.0"
RUN python -m pip install "mock>=2.0.0,<3.0.0"
RUN python -m pip install "flake8>=3.8.0,<6.0.0"
RUN python -m pip install "hypothesis>=3.27.0,<7.0.0"
RUN python -m pip install "mypy>=1.5.0,<1.6.0"
RUN python -m pip install "types-mock>=0.1.1"
RUN python -m pip install "types-setuptools>=57.0.0"
RUN python -m pip install "types-requests"
RUN python -m pip install "types-setuptools>=57.0.0"
RUN python -m pip install "black>=25.0.0"
RUN python -m pip install "cython-lint>=0.15.0"
RUN python -m pip install "isort>=5.0,<6.0"
run python -m pip install spacy


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