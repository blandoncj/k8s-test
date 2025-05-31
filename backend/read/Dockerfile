FROM eclipse-temurin:23-jdk-alpine

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

COPY src ./src

# build the app
RUN ./mvnw package -DskipTests

EXPOSE 8080

# execute the app (not CMD because recompile)
ENTRYPOINT ["java", "-jar", "target/inventory-ms-0.0.1-SNAPSHOT.jar"]
