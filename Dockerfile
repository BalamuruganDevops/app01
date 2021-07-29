FROM tomcat
RUN rm -fr /usr/local/tomcat/webapps/ROOT
COPY target/webapp01.war /user/local/tomcat/webapps/ROOT.war