# picture_mover
A dockerized script that moves pictures based on exif info into sorted directories

Simply build the docker imaage:

```sudo docker build . -t tgaleckas/picture_mover:0.1```

And use the docker image:

```
sudo docker run -it --name picture_mover \
                -v <local_source_directory>:/mnt/from \
                -v <local_destination_directory>:/mnt/to \
                tgaleckas/picture_mover:0.1
```
