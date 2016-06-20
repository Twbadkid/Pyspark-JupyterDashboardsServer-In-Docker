FROM ubuntu:latest
MAINTAINER koibadkid@gmail.com
RUN apt-get update
RUN apt-get install -y python-setuptools python-dev build-essential python-pip libblas-dev liblapack-dev gfortran libxml2-dev libxslt-dev openjdk-8-jdk wget npm
RUN wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz
RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-1.6.1-bin-hadoop2.6.tgz
RUN tar zxf scala-2.11.8.tgz
RUN tar zxf spark-1.6.1-bin-hadoop2.6.tgz
RUN mv scala-2.11.8 /usr/local/scala
RUN mv spark-1.6.1-bin-hadoop2.6 /usr/local/spark
ENV PATH $PATH:/usr/local/scala/bin:/usr/local/spark/bin
ENV SPARK_HOME /usr/local/spark
RUN rm scala-2.11.8.tgz
RUN rm spark-1.6.1-bin-hadoop2.6.tgz
RUN pip install numpy scipy jupyter boto py4j
RUN pip install jupyter_kernel_gateway jupyter_dashboards jupyter_dashboards_bundlers jupyter_declarativewidgets ipywidgets
RUN jupyter dashboards quick-setup --sys-prefix && jupyter dashboards_bundlers quick-setup --sys-prefix && jupyter declarativewidgets quick-setup --sys-prefix && jupyter nbextension enable --py widgetsnbextension
RUN npm install -g n
RUN n stable
WORKDIR /root
RUN mkdir jupyter_data
ENV IP='0.0.0.0'
ENV PORT=9060
ENV PUBLIC_LINK_PATTERN='http://0.0.0.0:9060'
ENV KERNEL_GATEWAY_URL='http://127.0.0.1:9033'
ENV NOTEBOOKS_DIR='/root/jupyter_data'
RUN npm install jupyter-dashboards-server
EXPOSE 9060
EXPOSE 4040
EXPOSE 8888
WORKDIR /root/jupyter_data
RUN echo "#!/bin/bash\n/root/node_modules/jupyter-dashboards-server/bin/jupyter-dashboards-server > /root/jupyter-dashboards-server.log &" > /root/run.sh
RUN echo "jupyter kernelgateway --KernelGatewayApp.port=9033 > /root/jupyter-kernel-gateway.log &" >> /root/run.sh
RUN echo "jupyter notebook --ip='0.0.0.0' \n/bin/bash" >>/root/run.sh
RUN mkdir -p /root/.ipython/profile_default/startup
RUN echo "import os\nimport sys\nspark_home = os.environ.get('SPARK_HOME', None)\nif not spark_home:\n    raise ValueError('SPARK_HOME environment variable is not set')\nsys.path.insert(0, os.path.join(spark_home, 'python'))\nsys.path.insert(0, os.path.join(spark_home, 'python/lib/py4j-0.9-src.zip'))\nexecfile(os.path.join(spark_home, 'python/pyspark/shell.py'))" > /root/.ipython/profile_default/startup/00-spark.py
RUN chmod 700 /root/run.sh
ENTRYPOINT ["/root/run.sh"]
