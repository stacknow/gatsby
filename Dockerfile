# Stage 1: Build the Gatsby application
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Copy the rest of the application code
COPY . .

# Build the Gatsby application
RUN yarn build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine

# Remove default Nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built static files from the build stage
COPY --from=build /app/public /usr/share/nginx/html

# Add custom Nginx configuration
RUN echo 'worker_processes 1; \
events { worker_connections 1024; } \
http { \
    include       mime.types; \
    default_type  application/octet-stream; \
    access_log    /dev/stdout; \
    error_log     /dev/stderr warn; \
    sendfile      on; \
    server { \
        listen       80; \
        server_name  localhost; \
        location / { \
            root   /usr/share/nginx/html; \
            index  index.html; \
            try_files $uri $uri/ /index.html; \
        } \
        location ~* \\.(?:manifest|appcache|html?|xml|json)$ { \
            expires -1; \
        } \
        location ~* \\.(?:css|js)$ { \
            expires 1y; \
            access_log off; \
            add_header Cache-Control "public"; \
        } \
        location ~* \\.(?:png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
            expires 1y; \
            access_log off; \
            add_header Cache-Control "public"; \
        } \
    } \
}' > /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]