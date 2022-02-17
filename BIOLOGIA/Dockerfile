FROM artifactory.apps.bancolombia.com/devops/python:3.7.9-slim-buster

USER root
COPY . .


ENV urlQueue="https://sqs.us-east-1.amazonaws.com/698662101601/nu0030001-fuentes-externas-dev-universidades.fifo"
ENV urlQueueAns="https://sqs.us-east-1.amazonaws.com/698662101601/queueEntregaaCSV.fifo"
ENV AWS_ACCESS_KEY_ID="AKIA2FK4BUJQ35FHF25R"
ENV AWS_SECRET_ACCESS_KEY="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"

RUN pip install -r requirements.txt -i https://artifactory.apps.bancolombia.com/api/pypi/pypi-bancolombia/simple --trusted-host artifactory.bancolombia.corp

#Expose port
EXPOSE 8080

RUN rm -rf /usr/local/lib/python3.7/site-packages/scrapyrt/conf/default_settings.py
COPY ./default_settings.py /usr/local/lib/python3.7/site-packages/scrapyrt/conf

RUN rm -rf /usr/local/lib/python3.7/site-packages/scrapyrt/resources.py
COPY ./resources.py /usr/local/lib/python3.7/site-packages/scrapyrt

RUN mkdir -p /opt/externalSources
COPY externalSources/ /opt/externalSources
 
WORKDIR /opt/externalSources/projects/biologia/scrapyBiologia/scrapyBiologia

ENTRYPOINT scrapyrt -i 0.0.0.0 -p 8080 & python listener.py
