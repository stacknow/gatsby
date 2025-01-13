# Stage 1: Build the Gatsby application
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package.json ./
# If you use npm instead of Yarn, skip copying `yarn.lock`
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Gatsby application
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine

# Remove default Nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built static files from the build stage
COPY --from=build /app/public /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]
