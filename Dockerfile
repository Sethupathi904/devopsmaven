# Use the official Node.js image as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React application
RUN npm run build

# Install a simple HTTP server to serve the build files
RUN npm install -g serve

# Expose port 5000
EXPOSE 5000

# Command to run the application
CMD ["serve", "-s", "build", "-l", "5000"]
