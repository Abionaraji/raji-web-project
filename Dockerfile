FROM maven as build
WORKDIR /app
COPY . .
RUN mvn install

FROM openjdk:11.0
WORKDIR /app
COPY --from=build /app/target/hello-world.war /app/
EXPOSE 9090
ADD target/hello-world.war hello-world.war
CMD [ "java","-war","/hello-world.war" ]