# Etapa 1: compila o projeto com Maven
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Copia todos os arquivos necessários
COPY pom.xml .
COPY src ./src

# Compila o projeto (gera target/*.jar)
RUN mvn clean package -DskipTests

# Etapa 2: imagem final leve só com o .jar
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

# Copia o .jar da build stage
COPY --from=builder /app/target/*.jar app.jar

# Executa o jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
