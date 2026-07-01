# Deploy to Tomcat using the pre-compiled WAR file
FROM tomcat:9-jdk21
WORKDIR /usr/local/tomcat/webapps

# Remove default Tomcat apps
RUN rm -rf *

# Copy the pre-compiled war file directly to ROOT.war so it serves at /
COPY dist/FYP1.war ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
