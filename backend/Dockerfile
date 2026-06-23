# Stage 1: Build
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
# Chạy offline copy trước để cache layer
RUN mvn dependency:go-offline -B
COPY src ./src
# Đảm bảo build ra file war/jar thành công
RUN mvn clean package -B -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-alpine
ENV TZ=Asia/Ho_Chi_Minh
RUN addgroup -S spring && adduser -S spring -G spring
WORKDIR /app

# Sửa lại để copy đúng file .war bạn đang có trong target
COPY --from=build /app/target/SportSwearShopSystem-0.0.1-SNAPSHOT.war app.jar
RUN chown spring:spring app.jar

USER spring:spring
EXPOSE 8083

ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"
