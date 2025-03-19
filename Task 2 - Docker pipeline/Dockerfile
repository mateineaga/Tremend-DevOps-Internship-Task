FROM node:19-bullseye

WORKDIR /app

COPY . ./

EXPOSE 8080

RUN npm install

RUN npm install express

CMD ["node", "notes.js"]