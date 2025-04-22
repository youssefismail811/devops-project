# Use an official Java runtime as a parent image
FROM openjdk:11-jre-slim

# Copy the jar file to the container
COPY target/your-app.jar /app/your-app.jar

# Define the command to run the application
ENTRYPOINT ["java", "-jar", "/app/your-app.jar"]

# Expose the port (if necessary)
EXPOSE 8080
