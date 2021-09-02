# web-hello-c

Extremely simple HTTP server (written in C) that responds on port 8000 with a hello message. The docker container is built using the "multi-stage build process, with the second build stage being `FROM scratch` (a completely empty file system with no Linux distro). For details on how to do that, see the Dockerfile.

I think this will build on many hardware architectures. :-)  I tested in on a Raspberry Pi 3B (arm32v7) and the image size ended up being 0.4MB (see below). That's pretty tiny considering that the extremely tiny `alpine` Linux distro base container with no workload inside at all is about 10 times larger than this:

```
-rw-r--r-- 1 pi pi 4098560 Apr 27 20:03 alpine.tar
-rw-r--r-- 1 pi pi  419840 Apr 28 14:39 web-hello-c.tar
```

