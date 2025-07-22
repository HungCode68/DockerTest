# Sử dụng image Tomcat 10.1.41 (dùng JDK 17 hoặc 21 tùy code bạn)
FROM tomcat:10.1.41-jdk21

# Xoá ứng dụng mặc định
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy file WAR đã build vào ROOT.war
COPY ./target/MyJavaWebApp.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8081 thay vì 8080
EXPOSE 8081

# Thay đổi port mặc định của Tomcat từ 8080 → 8081
RUN sed -i 's/port="8080"/port="8081"/' /usr/local/tomcat/conf/server.xml

CMD ["catalina.sh", "run"]
