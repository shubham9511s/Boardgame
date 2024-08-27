# First stage: Build the project
FROM maven:3.8.5-openjdk-17 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml file and the source code
COPY pom.xml .
COPY src ./src

# Build the project and create the JAR file
RUN mvn clean install 
#RUN mvn clean install -DskipTests

# Second stage: Run the application
FROM eclipse-temurin:17-jre-alpine

# Set the working directory inside the container
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy the JAR file from the builder stage and change ownership to the non-root user
COPY --from=builder /app/target/*.jar /app/app.jar
RUN chown appuser:appgroup /app/app.jar

# Switch to the non-root user
USER appuser

# Expose the application port (if needed)
EXPOSE 8085

# Command to run the application
#CMD ["java", "-jar", "app.jar"]
CMD ["java", "-Dcom.sun.management.jmxremote", "-Dcom.sun.management.jmxremote.port=12345", "-Dcom.sun.management.jmxremote.local.only=false", "-Dcom.sun.management.jmxremote.authenticate=false", "-Dcom.sun.management.jmxremote.ssl=false", "-jar", "app.jar"]


