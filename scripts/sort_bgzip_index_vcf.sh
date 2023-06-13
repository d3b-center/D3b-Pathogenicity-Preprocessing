#!/bin/bash

set -eo pipefail
bcftools sort $1 | bgzip -@ 8 -c > $2 && tabix $2