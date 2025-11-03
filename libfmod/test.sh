#!/bin/bash
# Helper script to run FMOD tests with correct library path and serial execution

export LD_LIBRARY_PATH="../fmodstudioapi20310linux/api/core/lib/x86_64:../fmodstudioapi20310linux/api/studio/lib/x86_64:$LD_LIBRARY_PATH"

cargo test -- --test-threads=1 "$@"
