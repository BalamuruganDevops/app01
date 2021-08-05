FROM tomcat:9.0.50
RUN rm -fr /usr/local/tomcat/webapps/ROOT
COPY target/webappv1.war /user/local/tomcat/webapps/ROOT.war