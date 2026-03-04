# =====================================================================
# Stage 1: Build — compile the Maven project and produce a WAR
# =====================================================================
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /app

# Copy POM first so dependency downloads are cached in a separate layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# =====================================================================
# Stage 2: Run — deploy the WAR inside Tomcat 9
# =====================================================================
FROM tomcat:9.0-jdk11-temurin

# Remove the default ROOT webapp
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Deploy our WAR as ROOT so the app is served at /
COPY --from=build /app/target/ocean-view-resort-1.0-SNAPSHOT.war \
     /usr/local/tomcat/webapps/ROOT.war

# Railway sets PORT at runtime; Tomcat listens on 8080 by default.
# We update server.xml to honour the PORT env variable if set.
RUN sed -i 's/port="8080"/port="${PORT:-8080}"/' /usr/local/tomcat/conf/server.xml

EXPOSE 8080

CMD ["catalina.sh", "run"]
