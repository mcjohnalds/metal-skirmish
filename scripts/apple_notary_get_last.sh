#!/usr/bin/env bash
xcrun notarytool history --keychain-profile notarytool-password | head -n 8
