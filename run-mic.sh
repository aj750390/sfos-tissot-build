jobs:
  build:
    runs-on: self-hosted
    container:
      image: coderus/sailfishos-platform-sdk-base:4.6.0.13
      volumes:
        - /home/user/hadk:/home/user/hadk
    steps:
      ...
