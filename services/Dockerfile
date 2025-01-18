FROM --platform=linux/amd64 python:3.11-slim

# Set the working directory
WORKDIR /app

# Copy the entire project to the container
COPY services services/
COPY database database/
COPY setup.py requirements.txt ./

# Install the dependencies and the `services` package
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install .

# Add a non-root user for security
RUN useradd -m appuser
USER appuser

# Set PYTHONPATH to include /app so the `services` package is discoverable
ENV PYTHONPATH=/app

# Expose the port for the microservice
EXPOSE 5001

# Run the microservice
CMD ["python", "services/movies.py"]