from setuptools import find_packages, setup

setup(
    name="microservices",
    version="0.1",
    description="Example of Microservices using Flask",
    author="Tamir",
    platforms=["any"],
    license="BSD",
    packages=find_packages(),  # Discover all packages (including services and subdirectories)
    install_requires=[
        "Flask==2.3.2",
        "requests==2.31.0",
    ],
)