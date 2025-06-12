# ----------- Build Stage -----------------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory inside build container
WORKDIR /build

# Copy the entire project directory (assumes repo is cloned fully)
COPY . .

# Build all modules without tests
RUN mvn clean install -DskipTests


# ----------- Runtime Stage --------------
FROM eclipse-temurin:17-jdk

# Set up a non-root user
RUN useradd -ms /bin/bash massbank

WORKDIR /home/massbank

# Copy all built jars from builder
COPY --from=builder /build/MassBank3-server/target/MassBank3-server*.jar ./MassBank3-server.jar
COPY --from=builder /build/MassBank3-export/target/MassBank3-export*.jar ./MassBank3-export.jar
COPY --from=builder /build/MassBank3-frontend/target/MassBank3-frontend*.jar ./MassBank3-frontend.jar
COPY --from=builder /build/MassBank3-mbtool/target/MassBank3-mbtool*.jar ./MassBank3-mbtool.jar
COPY --from=builder /build/MassBank3-similarity/target/MassBank3-similarity*.jar ./MassBank3-similarity.jar

# Default environment values (can be overridden in Easypanel UI)
ENV MB_DB_USER=massbank \
    MB_DB_PASSWORD=massbankpass \
    MB_DB_NAME=massbank \
    MB_DB_HOST=localhost \
    MB_DB_PORT=5432 \
    MB_DB_INIT=false \
    MB3_SERVER_PORT=8081 \
    MB3_FRONTEND_PORT=8080

# Expose default ports (can be remapped in Easypanel)
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083

# Set the default service to run (API server)
CMD ["java", "-jar", "MassBank3-server.jar"]
