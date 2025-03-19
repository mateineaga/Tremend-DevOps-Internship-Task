FROM node:19-bullseye

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

RUN npm install express

COPY . .

EXPOSE 8080

CMD ["node", "notes.js"]