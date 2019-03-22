FROM node:10.15.3-jessie
LABEL maintainer="Randy Coulman <randy@randycoulman.com>"

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
