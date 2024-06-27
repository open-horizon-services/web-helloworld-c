FROM ubuntu:22.04

RUN apt update && apt install -y build-essential

WORKDIR /
COPY webhello.c /

# If you plan to use "FROM scratch" then you need to statically compile
RUN gcc webhello.c -static -o /webhello

# Using a "scratch" second stage build to minimize container size
FROM scratch

# Copy the static binary from the first build stage
COPY --from=0 /webhello /bin/webhello

# Run it this way to ensure docker doesn't insert "sh -c" which fails in scratch
CMD [ "webhello" ]
