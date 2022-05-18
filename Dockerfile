FROM node:16.14.2-alpine3.14 as build
WORKDIR /app

RUN npm install -g @angular/cli

COPY ./my-app/package.json .
RUN npm install
COPY ./my-app .
RUN ng build

FROM nginx as runtime
COPY --from=build /app/dist/my-app /usr/share/nginx/html
