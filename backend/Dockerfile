FROM node:12.22.12-buster-slim
WORKDIR /app
COPY . .
RUN npm i
ENTRYPOINT [ "npm", "start" ]
EXPOSE 9000
