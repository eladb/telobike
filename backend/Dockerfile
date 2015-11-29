FROM node
COPY package.json /opt/telobike/
WORKDIR /opt/telobike
RUN npm install

COPY . /opt/telobike
ENTRYPOINT npm start
