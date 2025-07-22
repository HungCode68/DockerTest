FROM tomcat:10.1.41-jdk21

# Xóa ứng dụng mặc định
RUN rm -rf /usr/local/tomcat/webapps/*

# Đổi port Tomcat từ 8080 → 8081
RUN sed -i 's/port="8080"/port="8081"/' /usr/local/tomcat/conf/server.xml

# Copy WAR được Ant build vào ROOT.war của Tomcat
COPY dist/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8081

CMD ["catalina.sh", "run"]
