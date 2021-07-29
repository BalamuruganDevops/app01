FROM tomcat
RUN rm -fr /usr/local/tomcat/webapps/ROOT
COPY target/webappv1.war /user/local/tomcat/webapps/ROOT.war