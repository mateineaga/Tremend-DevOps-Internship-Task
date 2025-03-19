FROM node:19-bullseye

WORKDIR /usr/src/app

COPY "Task 2 - Docker pipeline/package.json" ./

RUN npm install

RUN npm install express

COPY "Task 2 - Docker pipeline/." ./

EXPOSE 8080

CMD ["node", "notes.js"]