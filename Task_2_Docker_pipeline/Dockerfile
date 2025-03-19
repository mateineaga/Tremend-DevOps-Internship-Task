FROM node:19-bullseye

WORKDIR /usr/src/app

COPY "Task_2_Docker_pipeline/package.json" ./

RUN npm install

RUN npm install express

COPY "Task_2_Docker_pipeline/." ./

EXPOSE 8080

CMD ["node", "notes.js"]