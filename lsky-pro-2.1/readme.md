- 参考：https://github.com/lsky-org/lsky-pro/discussions/753

```yaml
services:
  postgres:
    image: postgres:15
    container_name: lsky-pro-postgres
    environment:
      - POSTGRES_DB=lsky
      - POSTGRES_USER=lsky
      - POSTGRES_PASSWORD=vzGKLdj0tGWYrufpL2sM
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U lsky -d lsky"]
      interval: 30s
      timeout: 10s
      retries: 3

  lsky-pro:
    #build: ./conf
    image: lsky
    container_name: lsky-pro-app
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    ports:
      - "8000:80"
    volumes:
      - '/www/dk_project/projects/lsky/app/:/var/www/html/storage/app/'
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```
