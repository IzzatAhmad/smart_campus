# Stage 1: Build the project using Ant and JDK 11 (or appropriate JDK version)
FROM frekele/ant:1.10.3-jdk8 AS build
WORKDIR /app
COPY . .
RUN ant clean dist

# Stage 2: Deploy to Tomcat
FROM tomcat:9-jre8-alpine
WORKDIR /usr/local/tomcat/webapps
# Remove default apps
RUN rm -rf *
# Copy the compiled war file to ROOT.war so it serves at /
COPY --from=build /app/dist/*.war ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
