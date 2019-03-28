FROM cypress/base:10
LABEL maintainer="Randy Coulman <randy@randycoulman.com>"

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY . .

CMD ["npm", "test"]
