FROM node:8-alpine AS build-stage
WORKDIR /app
COPY . .
RUN npm install && \
    npm run build --prod

FROM nginx:alpine
## Copy a new configuration file setting listen port to 8080 (required to serve http traffic in Knative)
COPY ./docker/custom-nginx/default.conf /etc/nginx/conf.d/
## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*
## From 'build' stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=build-stage /app/dist/gcp-knative-gke-angular /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
