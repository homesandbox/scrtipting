# Build parent image
```
cd parent
docker build -t web-server:0.0.1 .
```

# Build app image
```
cd app
docker build -t myapp:0.0.1 .
```

# Run app
```
docker run -p8080:8080 myapp:0.0.1 
```