# Base image with JDK and Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy the whole project
COPY . .

# Build the project using Maven
RUN mvn clean install -DskipTests

# Final runtime image
FROM eclipse-temurin:17-jdk

# Create a non-root user for security
RUN useradd -ms /bin/bash massbank

# Set working directory
WORKDIR /home/massbank

# Copy compiled artifacts from the builder
COPY --from=builder /app/MassBank3-server/target/MassBank3-server*.jar ./MassBank3-server.jar
COPY --from=builder /app/MassBank3-export/target/MassBank3-export*.jar ./MassBank3-export.jar
COPY --from=builder /app/MassBank3-similarity/target/MassBank3-similarity*.jar ./MassBank3-similarity.jar
COPY --from=builder /app/MassBank3-frontend/target/MassBank3-frontend*.jar ./MassBank3-frontend.jar
COPY --from=builder /app/MassBank3-mbtool/target/MassBank3-mbtool*.jar ./MassBank3-mbtool.jar

# Copy example data (optional: replace with volume in production)
COPY data/ ./data/

# Set environment variables
ENV MB_DB_USER=massbank \
    MB_DB_PASSWORD=massbankpass \
    MB_DB_NAME=massbank \
    MB_DB_HOST=localhost \
    MB_DB_PORT=5432 \
    MB_DB_INIT=false \
    MB3_SERVER_PORT=8081 \
    MB3_FRONTEND_PORT=8080

# Set the default entrypoint to the server; override in docker-compose or Easypanel
CMD ["java", "-jar", "MassBank3-server.jar"]
