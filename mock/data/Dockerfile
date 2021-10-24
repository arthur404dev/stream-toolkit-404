FROM node:latest

WORKDIR /web/app

COPY package.json yarn.lock ./
RUN yarn
COPY . .
EXPOSE 4200
CMD ["yarn","start"]