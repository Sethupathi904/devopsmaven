FROM node:16 AS build

WORKDIR /app
COPY my-react-app/package.json my-react-app/package-lock.json ./
RUN npm install
COPY my-react-app/ ./
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
