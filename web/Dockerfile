FROM python:2.7
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN mkdir /code
WORKDIR /code
ADD . /code
CMD /usr/local/bin/gunicorn config.wsgi:application -w 2 -b :8000