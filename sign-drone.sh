#!/bin/sh

set +x

drone lint --trusted
drone fmt --save
drone sign --save prod9/p9
