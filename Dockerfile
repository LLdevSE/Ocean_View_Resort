# =====================================================================
# Stage 1: Build — compile the Maven project and produce a WAR
# =====================================================================
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /app

# Copy everything and build (target/ is gitignored so it won't be in context)
COPY . .
RUN mvn clean package -DskipTests -B

# =====================================================================
# Stage 2: Run — deploy the WAR inside Tomcat 9
# =====================================================================
FROM tomcat:9.0-jdk11-temurin

# Remove the default ROOT webapp
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# pom.xml sets <finalName>ocean-view-resort</finalName>
# so Maven produces ocean-view-resort.war (no version suffix)
COPY --from=build /app/target/ocean-view-resort.war \
     /usr/local/tomcat/webapps/ROOT.war

# Railway sets PORT at runtime; update server.xml to honour it
RUN sed -i 's/port="8080"/port="${PORT:-8080}"/' /usr/local/tomcat/conf/server.xml

EXPOSE 8080

CMD ["catalina.sh", "run"]
