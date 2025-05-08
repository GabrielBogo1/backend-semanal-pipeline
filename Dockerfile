FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app
COPY target/*.jar app.jar

# Executa o .jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]