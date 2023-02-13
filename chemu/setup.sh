#!/bin/bash
python3 -m venv venv
source venv/bin/activate
pip3 install wheel
pip3 install flask
pip3 install .