FROM ubuntu:22.04

VOLUME /server
WORKDIR /server
EXPOSE 777/tcp 27015/tcp

ENV MAX_PLAYERS=6 \
    SERVER_NAME="My Server" \
    SERVER_PASSWORD="123456seven" \
    WORLD_SAVE_NAME="Cascade"

RUN apt update && apt install -y sudo unzip wine64 wget

RUN mkdir /app && \
    cd /app && \
    wget 'https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_2.6.0/DepotDownloader-linux-x64.zip' && \
    unzip DepotDownloader-linux-x64.zip && \
    rm DepotDownloader-linux-x64.zip DepotDownloader.xml && \
    chmod +x DepotDownloader

COPY app.sh /app
CMD [ "/app/app.sh" ]
