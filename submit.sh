#!/bin/bash
NAME="hanyangdu"
echo "Creating submission zip $NAME.zip..."
git archive -o $NAME.zip HEAD
echo "Done!"