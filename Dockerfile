FROM tomcat:10.1.41-jdk21

# Xoá ứng dụng mặc định
RUN rm -rf /usr/local/tomcat/webapps/*

# Đổi cổng Tomcat từ 8080 thành 8085
RUN sed -i 's/port="8080"/port="8085"/' /usr/local/tomcat/conf/server.xml

# Copy WAR đã build vào Tomcat (ROOT.war)
COPY build/WebApplication.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8085

CMD ["catalina.sh", "run"]
