#!/bin/bash

echo "Copying Docker unit files..."
cp /vagrant/unit-files/* /etc/systemd/system/

echo "Reloading systemd"
systemctl daemon-reload
