#!/usr/bin/env python3
# Import socket module
# Import regex module

import socket
import re

thishostname = socket.gethostname()

orgStr = "<unique-host-id></unique-host-id>"
repStr = "<unique-host-id>{}</unique-host-id>".format(thishostname)

def replace(filepath, text, subs, flags=0):
    with open(file_path, "r+") as file:
        file_contents = file.read()
        text_pattern = re.compile(re.escape(text), flags)
        file_contents = text_pattern.sub(subs, file_contents)
        file.seek(0)
        file.truncate()
        file.write(file_contents)

file_path="controller-info.xml"
text=orgStr
subs=repStr

replace(file_path, text, subs)
