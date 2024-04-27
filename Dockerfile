FROM gcr.io/distroless/static-debian12:nonroot
ENTRYPOINT ["/$REPO"]
COPY $REPO /