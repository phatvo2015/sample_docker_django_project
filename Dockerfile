# Stage 1: Install system packages (using apt)
ARG PYTHON_VERSION=3.7.11-slim
FROM python:${PYTHON_VERSION} as base-image
ENV PYTHONUNBUFFERED 1
# Add some system depenpencies for python packages
RUN apt-get update -y \ 
    && apt-get install --no-install-recommends -y gcc libc6-dev libpq-dev libffi-dev python3-dev dumb-init

# Stage 2: Create least privileged user and group to run our application
RUN groupadd -g 1000 django && useradd -u 1000 -ms /bin/bash -g django django
RUN mkdir /home/django/code && chown django:django /home/django/code

USER django
# Stage 3: Install python packages (using pip)
# They will install packages defined in requirements.txt using Pip tool
WORKDIR /home/django/code
COPY --chown=django:django requirements.txt /home/django/code
# The Python installed depenpencies will be in django home directory
ENV PATH=/home/django/.local/bin:$PATH
RUN pip install --user -r requirements.txt
# Stage 4: Copy all source code
# Copy pip installation result. As we use --user option, they are store in user home's .local directory
COPY --chown=django:django . /home/django/code

ENTRYPOINT ["dumb-init", "--"]
CMD ["gunicorn", "-b 0.0.0.0:80", "docker_django_sample_app.wsgi:application"]

