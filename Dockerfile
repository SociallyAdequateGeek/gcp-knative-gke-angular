FROM node:8-alpine AS build-stage
WORKDIR /app
COPY . .
RUN npm install && \
    npm run build --prod

FROM nginx:alpine
## Change nginx default port to 8080 - required to serve http traffic in Knative
RUN cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig && \
    sed -i 's/listen[[:space:]]*80;/listen 8080;/g' /etc/nginx/conf.d/default.conf
## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*
## From 'build' stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=build-stage /app/dist/gcp-knative-gke-angular /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
