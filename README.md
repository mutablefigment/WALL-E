# WALL-E Firmware

![Logo](./res/wall-e-logo.svg)

The firmware and related tools for my custom built "WALL-E" robot.

## Build it

This project is built using nix develop, but you can also just run it
with zig installed.

### Build requirements

- raylib
- zmq

### Build command

```sh
zig build
```

## Run it

```sh
zig build run-debugger # for running the debugging client
```
