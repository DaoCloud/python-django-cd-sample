FROM python:2.7
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN mkdir /code
WORKDIR /code
ADD . /code
EXPOSE 8000
RUN /code/manage.py syncdb --noinput


CMD docker-entrypoint.sh