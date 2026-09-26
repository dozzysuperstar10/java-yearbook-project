FROM eclipse-temurin:17-jre

WORKDIR /app

COPY target/yearbook-lambda-1.0.0.jar app.jar

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]
