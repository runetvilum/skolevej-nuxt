FROM ubuntu
ENV TZ=Europe/Copenhagen
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /usr/src/app

# Install app dependencies
RUN apt-get update && apt-get install -y build-essential python gdal-bin libgdal-dev git curl \
ca-certificates \
fonts-liberation \
libappindicator3-1 \
libasound2 \
libatk-bridge2.0-0 \
libatk1.0-0 \
libc6 \
libcairo2 \
libcups2 \
libdbus-1-3 \
libexpat1 \
libfontconfig1 \
libgbm1 \
libgcc1 \
libglib2.0-0 \
libgtk-3-0 \
libnspr4 \
libnss3 \
libpango-1.0-0 \
libpangocairo-1.0-0 \
libstdc++6 \
libx11-6 \
libx11-xcb1 \
libxcb1 \
libxcomposite1 \
libxcursor1 \
libxdamage1 \
libxext6 \
libxfixes3 \
libxi6 \
libxrandr2 \
libxrender1 \
libxss1 \
libxtst6 \
lsb-release \
wget \
xdg-utils
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get -y install nodejs
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN make customize
RUN npm run build
EXPOSE 3000
CMD [ "npm", "start" ]