FROM openjdk:21
WORKDIR /app
COPY target/AuthService-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8081
COPY wait-for-it.sh /wait-for-it.sh
ENTRYPOINT ["/wait-for-it.sh", "postgres:5432", "--", "java", "-jar", "app.jar"]